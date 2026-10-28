-- Match the Prometheus polkit dialog's dark glass treatment.
hl.layer_rule({ match = { namespace = "^(prometheus-askpass)$" }, blur = true })
hl.layer_rule({ match = { namespace = "^(prometheus-askpass)$" }, ignore_alpha = 0.1 })
