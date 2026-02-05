.PHONY: apply forward forward-prom forward-grafana stop-forward status-forward clean reset

apply:
	kubectl apply -f observability-ns.yaml
	kubectl apply -f Loki
	kubectl apply -f Promtail
	kubectl apply -f Prometheus
	kubectl apply -f NodeExporter
	kubectl apply -f Grafana

forward:
	$(MAKE) stop-forward
	kubectl -n observability port-forward svc/prometheus 9090:9090 >/tmp/pf-prom.log 2>&1 &
	kubectl -n observability port-forward svc/grafana 3000:3000 >/tmp/pf-grafana.log 2>&1 &

forward-prom:
	kubectl -n observability port-forward svc/prometheus 9090:9090

forward-grafana:
	kubectl -n observability port-forward svc/grafana 3000:3000

stop-forward:
	pkill -f "kubectl -n observability port-forward svc/prometheus 9090:9090" || true
	pkill -f "kubectl -n observability port-forward svc/grafana 3000:3000" || true

status-forward:
	pgrep -af "kubectl -n observability port-forward svc/prometheus 9090:9090" || true
	pgrep -af "kubectl -n observability port-forward svc/grafana 3000:3000" || true

clean:
	kubectl delete -f Grafana || true
	kubectl delete -f Prometheus || true
	kubectl delete -f Promtail || true
	kubectl delete -f NodeExporter || true
	kubectl delete -f Loki || true
	kubectl delete -f observability-ns.yaml || true

reset:
	$(MAKE) clean
	kubectl delete pvc -n observability --all || true
