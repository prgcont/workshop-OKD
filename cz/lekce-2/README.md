# Lekce 2


* [Persistent Volumes](##Persistent-volumes)
* [Image streams](##Image-streams)
* [Source to Image (s2i)](##Source-to-Image-(s2i))
* [Šablony(Template)](##Šablony-(Template))

## Persistent volumes
Kontejnery by ve své podstatě měly být bezstavové. Bohužel ne všechny aplikace mohou být takové. Databáze, která nemá stav, nám bude k ničemu. Docker proto přinesl možnost připojit adresáře z hostujícího systému přímo do kontejneru. Kubernetes/OpenShift jdou dále - umožňují do kontejneru připojít síťová uložiště jako NFS, CEPH atp.

Pro zpřístupnění síťového úložiště musí administrátor OpenShift vytvořit PersistentVolume. Pokud pak chce aplikace/vývojář tento persisten volume použít, musí v rámci svého projektu vytvořit Persistent Volume Claim, který mu daný Persistent volume zpřístupní (a to i bez znalosti jaká technologie pod ním stojí).

### Vytvoření NFS Persistent Volume v OpenShift Origin

* Nainstalujeme NFS na náš server
```
yum install nfs-utils
systemctl enable nfs.service
systemctl start nfs.sercie
```

* Vytvoříme NFS exportované filesystémy
```
setsebool -P virt_use_nfs 1
mkdir -p /srv/pv/pv01 
chown nfsnobody:nfsnobody /srv/pv/pv01/
chmod 777 /srv/pv/pv01/
```

* Do /etx/exports.d/pv01.exports vložíme:
```
/srv/pv/pv01/ *(rw,all_squash)
```

* Exportujeme filesystém
```
exportfs -a
```

* Definujeme pv.json pro OpenShift Origin
```
kind: List
metadata: {}
apiVersion: v1
items:
- apiVersion: v1
  kind: PersistentVolume
  metadata:
    name: pv01
  spec:
    accessModes:
    - ReadWriteOnce
    capacity:
      storage: 10Gi
    nfs:
      path: /srv/pv/pv01
      server: #vase ip
    persistentVolumeReclaimPolicy: Recycle
```

* Importujeme pv.json do OpenShift Origin
```
oc import -f pv.json
```

* Zkontrolujeme pv
```
oc get pv
```


## Image Streams

### Vytvoření Image Strem

1. Vytvoříme image 
```
docker build -t ldj/os-demo
```

2. Nahrajeme ji do registrů
```
docker push ldj/os-demo
```

3. Vytvoříme my-image-stream.json


4. Importujeme image do OpenShift Origin
oc create -f is.yaml



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
## Source to Image (s2i)
