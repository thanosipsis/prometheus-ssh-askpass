"""Cache policy checks with synthetic credentials and no desktop/keyring access."""
import importlib.machinery
import os
from pathlib import Path
import sys
import tempfile
import types
import unittest
from unittest.mock import patch

adapter = importlib.machinery.SourceFileLoader(
    "askpass", str(Path(__file__).resolve().parents[1] / "bin/prometheus-askpass")
).load_module()


class CacheTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.value = b"synthetic-test-passphrase"
        self.reads = 0
        self.locked = False
        self.attributes = None
        self.environment = patch.dict(os.environ, {"SSH_ASKPASS_PROMPT": ""})
        self.environment.start()
        self.addCleanup(self.environment.stop)
        item = types.SimpleNamespace(is_locked=lambda: False, get_secret=self.read_secret)
        collection = types.SimpleNamespace(is_locked=lambda: self.locked,
                                           search_items=lambda attrs: self.items(attrs, item))
        fake = types.SimpleNamespace(dbus_init=lambda: object(), get_all_collections=lambda bus: [collection])
        modules = patch.dict(sys.modules, {"secretstorage": fake})
        modules.start()
        self.addCleanup(modules.stop)

    def read_secret(self):
        self.reads += 1
        return self.value

    def items(self, attributes, item):
        self.attributes = attributes
        return [item]

    def cached(self, prompt="Enter passphrase for key '/example/key': "):
        return adapter.cached_passphrase(prompt, self.directory.name)

    def test_existing_passphrase_and_exact_schema(self):
        self.assertEqual(self.cached(), self.value.decode())
        self.assertEqual(self.attributes, {"server": "ksshaskpass", "user": "/example/key", "xdg:schema": "org.qt.keychain"})

    def test_repeat_does_not_return_stale_secret(self):
        self.assertIsNotNone(self.cached())
        self.assertIsNone(self.cached())

    def test_security_key_pin_never_reads_keyring(self):
        self.assertIsNone(self.cached("Enter PIN for ED25519-SK key SHA256:dummy: "))
        self.assertEqual(self.reads, 0)

    def test_confirm_and_notice_never_read_keyring(self):
        for mode in ("confirm", "none"):
            with patch.dict(os.environ, {"SSH_ASKPASS_PROMPT": mode}):
                self.assertIsNone(self.cached())
        self.assertEqual(self.reads, 0)

    def test_locked_collection_falls_back_without_reading(self):
        self.locked = True
        self.assertIsNone(self.cached())
        self.assertEqual(self.reads, 0)

    def test_non_file_prompt_does_not_query_keyring(self):
        self.assertIsNone(self.cached("user@example's password: "))
        self.assertEqual(self.reads, 0)

    def test_invalid_cached_value_falls_back(self):
        self.value = b"line one\nline two"
        self.assertIsNone(self.cached())

    def test_ssh_add_prompt_uses_same_identifier(self):
        self.assertIsNotNone(self.cached("Enter passphrase for /example/key (will confirm each use): "))
        self.assertEqual(self.attributes['user'], '/example/key')


if __name__ == '__main__':
    unittest.main()
