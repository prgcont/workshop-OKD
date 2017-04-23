# Lekce 4

* Monitoring (Prometheus)
* Anisble
* Základní troubleshouting (logy, exec, ...)



# Monitoring

## Instalace promethea


* Přihlásíme se jako system admin
```
oc login -u system:admin
```
* Vytvoříme workshop-infra namespace
```
oc new-project ce-infra
```
* Vytoříme service account a nastavíme mu cluster-reade roli
```
oc create serviceaccount metrics -n ce-infra
oc adm policy add-cluster-role-to-user cluster-reader system:serviceaccount:ce-infra:metrics
```
* Zprocesujeme template pro promethea
oc proces -f https://raw.githubusercontent.com/fabric8io/templates/master/default/template/prometheus.json -n ce-infra | oc apply -f -

* Nainstalujueme grafanu

* Přistoupíme do grafany a nastavíme promethea jako datovy zdroj a improtujeme kubernetes template
