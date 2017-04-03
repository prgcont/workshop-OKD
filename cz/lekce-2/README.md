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
docker build -t $vaseimage demoapp
```

2. Nahrajeme ji do registrů
```
docker push $vaseimage
```

3. Upravime *demo-openshift/stream.json* 


4. Importujeme image do OpenShift Origin
```
oc create -f stream.json
```



## Šablony (Template)
Šablony umožňují parametrizovaně definovat objekty pro OpenShift - objektem může být například: Service, build configuration, Deployment configuration... Šablona dále může definovat seznam štítků (label), které budou aplikovány na každý objekt vytvořený šablonou.

Šablony můžete zpracovat pomocí přikazové řádky nebo webové konzole.


### Zprávování existující šablony
Vezmeme šablonu přiloženou k tomuto repu a nasadíme je do našeho OpenShift Origin.
```
oc create -f *demo-openshift/temp.yaml*
```

### Modifikace šablony
Otevřeme existující šablonu v OpenShift Origin
```
oc edit template <jmeno?
```
## Source to Image (s2i)

https://github.com/openshift/source-to-image/releases

Linux - https://github.com/openshift/source-to-image/releases/download/v1.1.5/source-to-image-v1.1.5-4dd7721-linux-amd64.tar.gz
OS X - https://github.com/openshift/source-to-image/releases/download/v1.1.5/source-to-image-v1.1.5-4dd7721-darwin-amd64.tar.gz

### Tvorba S2I

Z čeho se S2I skládá:
 - z běhového prostředí - tzn. toho, co když se spustí kontainer, naběhne
 - z S2I skriptů, které mají na starosti hlavní dvé fáze
   - assembly - skript, který provede převod zdrojových kódů 
   - run - skript, který spustí běhové prostředí

### Ukázka
Velmi jednoduchý s2i je https://github.com/containers-prague/workshop-OpenShiftOrigin/tree/master/cz/lekce-2/simple-s2i

```
FROM openshift/base-centos7
MAINTAINER Miloslav Vlach <miloslav.vlach@gmail.com>
LABEL io.k8s.description="S2I for static html content" \
      io.k8s.display-name="rohlik-httpd-24" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="static html"
RUN 	yum -y install epel-release httpd.x86_64  \
	mc htop dstat telnet net-tools && \
	mkdir -p /run/httpd && chown 777 -R /run/httpd/ && \
	yum clean all
COPY ./.s2i/bin/ /usr/libexec/s2i
ADD ./httpd.conf /etc/httpd/conf
RUN chown -R 1001:1001 /opt/app-root
USER 1001
EXPOSE 8080

CMD ["usage"]
```

### Jak S2I vytvořit
#### Build kontajneru
```
# cd workshop-OpenShiftOrigin/cz/lekce-2/simple-s2i
# docker build -t simple-s2i:latest .
```

Otestování s2i
```
s2i https://github.com/mvlach/html.git simple-s2i:latest testovaciaplikace:latest
docker run -d -p 8080:8080 --name=testovaci-aplikace testovaciaplikace:latest

Miloslav-MacBook-Pro:html mvlach$ curl http://localhost:8080/
<h1>Hello World</h1>
```

#### Nahrání do openshiftu
```
# oc login ...
# export TOKEN=$(oc whoami -t )
# export DOCKER_REGISTRY=$(oc get svc/docker-registry -n default -o yaml | grep clusterIP: | awk '{print $2}')
# docker login --username=developer -p $TOKEN $DOCKER_REGISTRY:5000
# docker tag simple-s2i:latest $DOCKER_REGISTRY:5000/openshift/simple-s2i:latest
# docker push $DOCKER_REGISTRY:5000/openshift/simple-s2i:latest
# docker tag simple-s2i:latest $DOCKER_REGISTRY:5000/openshift/simple-s2i:latest --insecure=true
```

Nyní můžeme vytvořit novou aplikaci
```
# oc new-app simple-s2i~https://github.com/mvlach/html.git
```

Teď můžeme pozorovat, jak se vytváří nový kontainer.
