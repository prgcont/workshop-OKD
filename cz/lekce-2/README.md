# Lekce 2


* [Persistent Volumes](#Persistent-volumes)
* [Image streams](#Image-streams)
* [Source to Image (s2i)](#Source-to-Image-(s2i))
* [Šablony(Template)](#Šablony-(Template))

## Persistent volumes
Kontejnery by ve své podstatě měly být bezstavové. Bohužel ne všechny aplikace mohou být takové. Databáze, která nemá stav, nám bude k ničemu. Docker proto přinesl možnost připojit adresáře z hostujícího systému přímo do kontejneru. Kubernetes/OpenShift jdou dále - umožňují do kontejneru připojít síťová uložiště jako NFS, CEPH atp.

Pro zpřístupnění síťového úložiště musí administrátor OpenShift vytvořit PersistentVolume. Pokud pak chce aplikace/vývojář tento persisten volume použít, musí v rámci svého projektu vytvořit Persistent Volume Claim, který mu daný Persistent volume zpřístupní (a to i bez znalosti jaká technologie pod ním stojí).

### Vytvoření NFS Persistent Volume v OpenShift Origin

1. Nainstalujeme NFS na náš server

2. Vytvoříme NFS exportované filesystémy

3. Definujeme PV v OpenShift Origin

## Image Streams

### Vytvoření Image Strem

1. Vytvoříme image 

2. Nahrajeme ji do registrů

3. Vytvoříme my-image-stream.json

4. Importujeme image do OpenShift Origin


## Source to Image (s2i)

## Šablony (Template)
Šablony umožňují parametrizovaně definovat objekty pro OpenShift Origin - objektem může být například: Service, build configuration, Deployment configuration... Šablona dále může definovat seznam štítků (label), které budou aplikovány na každý objekt vytvoření šablonou.

Šablony můžete zpracovat pomocí přikazové řádky nebo webové konzole.


### Zprávování existující šablony
Vezmeme šablonu přiloženou k tomuto repu a nasadíme je do našeho OpenShift Origin.
```
oc process -f #TODO | co create -f -
```

### Modifikace šablony
Otevřeme existující šablonu v OpenShift Origin
```
oc edit template #TODO jmeno
```
