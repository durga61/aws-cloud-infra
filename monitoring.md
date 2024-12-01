
# Prometheus-grafana
Verify Services

kubectl get svc -n prometheus

edit the Prometheus-grafana service:

kubectl edit svc prometheus-grafana -n prometheus
change ‘type: ClusterIP’ to 'LoadBalancer'

Username: admin Password: prom-operator

Import Dashboard ID: 1860

Exlore more at: https://grafana.com/grafana/dashboards/
