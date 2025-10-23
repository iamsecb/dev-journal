---
title: AWS WAF ALB Mind Notes
tags:
 - alb
 - waf
---

# About

*Captures my thought process to illuminate reasoning*.

## ALB Logs

ALB provides 2 types of logs; **access logs** and **connection logs**. While the access logs are self explanatory and should be be enabled, the connection logs appear to provide value in inspecting TLS connection details. These logs while useful for diagnosing connection issues, it may not provide value in terms of a cost benefit to capture all the logs for every connection. The security baseline also makes no mention of connection logs. Therefore it may only be required to be enabled when connection issues are encountered.


