# Stack de Observabilidad (Local/Kind)

Configuración mínima y educativa para ejecutar **Grafana + Prometheus + Loki** en kind.
Este repo es intencionalmente simple para desarrollo local y demos.

**Qué incluye**
- Grafana 10.4.2
- Prometheus 2.51.2
- Loki 2.9.8
- Node Exporter 1.7.0 (métricas del nodo)
- Promtail 2.9.8 (logs del nodo)
- Persistencia simple vía PVCs (`standard`)
- Servicios `ClusterIP` (acceso mediante port-forward)

**Requisitos**
- `kind`, `kubectl`
- StorageClass `standard` (por defecto en kind con `rancher.io/local-path`)

**Inicio rápido**
```bash
kubectl apply -f observability-ns.yaml
kubectl apply -f Loki
kubectl apply -f Promtail
kubectl apply -f Prometheus
kubectl apply -f NodeExporter
kubectl apply -f Grafana
```
O usa:
```bash
make apply
```

**Acceso**
```bash
kubectl -n observability port-forward svc/prometheus 9090:9090
kubectl -n observability port-forward svc/grafana 3000:3000
```
Prometheus: http://localhost:9090  
Grafana: http://localhost:3000

Atajos con Makefile:
```bash
make forward
make status-forward
make stop-forward
```
Logs:
- `/tmp/pf-prom.log`
- `/tmp/pf-grafana.log`
Ver logs:
```bash
tail -f /tmp/pf-prom.log
tail -f /tmp/pf-grafana.log
```

**Login de Grafana**
- Usuario: `admin`
- Contraseña: `admin` (por defecto)

**Persistencia de datos**
- Los PVCs usan `storageClassName: standard`
- Borrar PVCs elimina dashboards y datos de Prometheus/Loki

**Solución de problemas (pasos concretos)**
1. Verifica recursos básicos:
```bash
kubectl -n observability get pods
kubectl -n observability get svc
kubectl -n observability get pvc
```
2. Si un Pod no arranca:
```bash
kubectl -n observability describe pod <pod-name>
kubectl -n observability logs <pod-name>
```
3. Si un PVC queda en `Pending`:
```bash
kubectl get sc
kubectl -n observability describe pvc <pvc-name>
```
4. Si Prometheus no muestra targets:
```bash
kubectl -n observability port-forward svc/prometheus 9090:9090
```
Abre http://localhost:9090/targets y revisa el estado.

**Limpieza**
```bash
kubectl delete -f Grafana
kubectl delete -f Prometheus
kubectl delete -f Promtail
kubectl delete -f NodeExporter
kubectl delete -f Loki
kubectl delete -f observability-ns.yaml
```
O usa:
```bash
make clean
make reset
```

**Notas de diseño (Local/Educativo)**
- Sin PSA/PSS labels, HPA, PDB, NetworkPolicy ni RBAC extra.
- Imágenes fijadas a tags estables para reproducibilidad.

**Arquitectura rápida**
```
          ┌──────────────┐
          │   Grafana    │
          │   :3000      │
          └──────┬───────┘
                 │
                 │ datasource
                 ▼
┌──────────────┐  ┌──────────────┐
│ Prometheus   │  │    Loki      │
│    :9090     │  │    :3100     │
└──────┬───────┘  └──────────────┘
       │
       │ scrape
       ▼
┌──────────────┐
│ node-exporter│
│    :9100     │
└──────────────┘

Promtail -> Loki (push)
```

**Primeros pasos en Grafana**
1. Entra a Grafana y verifica datasources.
2. Verifica targets en Prometheus: http://localhost:9090/targets (deben estar `UP`).
2. Importa dashboard 1860 (Node Exporter Full).
3. Explora logs en Explore con Loki (job `varlogs`).
