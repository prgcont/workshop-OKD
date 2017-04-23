# Lekce 4

# Monitoring

## Instalace promethea


* Přihlásíme se jako system admin
```
oc login -u system:admin
```
* Vytvoříme workshop-infra namespace
```
oc new-project prom
```
* Vytoříme service account a nastavíme mu cluster-reade roli
```
oc create serviceaccount metrics -n prom
oc adm policy add-cluster-role-to-user cluster-reader system:serviceaccount:prom:metrics
```
* Zprocesujeme template pro promethea
```
oc process -f https://raw.githubusercontent.com/fabric8io/templates/master/default/template/prometheus.json | oc apply -n prom  -f -
```
* Vytorime route
```
oc expose service prometheus --port=9090 -n prom
```

* Nainstalujueme grafanu a route:
```
oc new-app jtslear/openshift-grafana
oc expose service openshift-grafana -n prom
```

* Přistoupíme do grafany a nastavíme promethea jako datovy zdroj a improtujeme kubernetes template
zdroj: http://prometheus
dashboard: https://raw.githubusercontent.com/instrumentisto/grafana-dashboard-kubernetes-prometheus/master/dashboard.json


## Princip promethea

Prometheus periodicky stahuje metriky, ukládá je (používá [LevelDB](https://github.com/google/leveldb)) a poté nad nimi umožňuje provádět dotazy. Webové rozhraní (na portu `9090`) dokáže zobrazovat i základní grafy, ale na vizualizaci je vhodnější použít grafanu.


![Architektura promethea](https://prometheus.io/assets/architecture.svg)

## Alerty

Nad metrikami je možné dělat různé dotazy a podle těchto dotazů poté generovat alerty. Nicméně Prometheus sám o sobě neposílá notifikace, ale pouze generuje alerty a předává je dál. K posílání notifikací slouží [AlertManager](https://github.com/prometheus/alertmanager).

Jedna z největších výhod oproti legacy monitorovačím řešením (např. Nagios, Zabbix) spočívá v tom, že Prometheus definuje všechny alerty na serveru a také se dokáže vyrovnat s dynamickou infrastrukturou.


Postup je tedy následující:

1. Prometheus vyhodností dotaz
2. Prometheus vytvoří alert a předá jej AlertManageru
3. AlertManager alert zpracuje (seskupí, pozdrží, zahodí, ...)
4. AlertManager posílá notifikaci

Alerty se definují v textové formě a je vhodné pro ně použít nějakou formou config managementu nebo alespoň ConfigMap.

* Volné místo na filesystému (obsazeno více než 80 %)

```
ALERT FilesystemFull
  IF node_filesystem_avail / node_filesystem_size < 0.2
  ANNOTATIONS {description="Less than 20% available", summary="Full filesystem on {{ $labels.instance }} mountpoint {{ $lables.mountpoint"}
```

* Uptime (víc než 127 dnů, skupina serverů `c2`)

```
ALERT C2LongUptime
  IF (time() - node_boot_time{group="c2"}) > 10972800
  ANNOTATIONS {description="Uptime on {{ $labels.instance }} is longer than 127 days", summary="Long uptime on {{ $labels.instance}}"}
```

* Předvídat zaplnění disku (víc než 90 % v následujících 30-ti dnech)

```
ALERT FilesystemFullIn30Days
  IF predict_linear(node_filesystem_avail[5h], 30 * 24 * 3600) < (node_filesystem_size * 0.1)
  FOR 10h
  ANNOTATIONS {description="There will be less than 10% in less than 30 days.", summary="Full filesystem on {{ $labels.instance }} mountpoint {{ $lables.mountpoint}}"}
```
