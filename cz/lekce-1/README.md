# Lekce 1

* [Co je OpenShift](#co-je-openshift)
* [Základní pojmy v OpenShiftu](#základní-pojmy-v-openshiftu)
* [Instalace](#instalace)
* [Deployment ukázkové aplikace](#deployment-ukázkové-aplikace)

## Co je OpenShift

OpenShift je platforma pro správu a nasazení software založená na linuxových kontejnerech. 
Ve své podstatě se jedná o distribuci Kubernetes s použitím docker kontejnerů a DevOps nástrojů pro urychlení a usnadnění vývoje aplikací.

## Základní pojmy v OpenShiftu

OpenShift (a potažmo Kubernetes) staví na několika základních kamenech, které využijeme při nasazování aplikací.

### Master/Node

Pokud nasazujeme OpenShift v produkci, očekává se využití clusteru strojů - tedy více než 1 stroje, by bylo dosaženo požadované dostupnosti i v případě poruch a výpadků. 

V OpenShift clusteru najdeme 2 typy strojů - Master a Node. **Master** (nebo více masterů) obsahuje hlavní komponenty systému - API server, kontroler, etcd a má na starost správu 
a plánování podů pro jednotlivé nody. **Node** poskytuje prostředí pro běh kontejnerů.

### Pod

Pod je skupina jednoho nebo více kontejnerů a jejich konfigurace, včetně například sdíleného úložiště. Kontejnery v podu jsou vždy plánovány společně na jeden node.

### DeploymentConfig/ReplicationController

Deployment je v OpenShiftu ve své podstatě ReplicationController, který je vytvářen manuálně nebo nebo na základě různých událostí v systému.

ReplicationController slouží k zajištění a udržení určitého počtu replik daného Podu v běhu. 

### Service

Pody jsou smrtelné. Vznikají a zanikají v závislosti na mnoha proměnných. Abychom byli schopni připojit se k aplikaci i po smrti jednoho a vytvoření nového podu, je třeba 
vytvořit další abstrakci - touto abstrakcí je práve objekt Service.

### Route

Route nám umožňuje přidělit Service zvenku přístupný hostname (www.example.com).

### Registry

Registry je služba, která slouží k ukládání Docker image-í a jejich následné distribuci.

## Instalace

Pro základní experimentování s OpenShiftem je dobré vědět jak spustit vývojářské prostředí.

Základní URL pro získání software je https://github.com/openshift/origin/releases.

Verze, která je stabilní se kažnou chvíli mění, v tuto chvíli doporučuji 1.3.1 (máme v produkci), nebo 1.4.1 (do produkci budeme dávat). Verze 1.5.0-aplha3 je v tuto chvíli jen na hraní a reportování bugfixů.

Stáhneme archiv odpovídající použitému operačnímu systému:

* openshift-origin-client-tools-v1.4.1-3f9807a-linux-64bit.tar.gz
* openshift-origin-client-tools-v1.4.1-3f9807a-mac.zip

Archiv rozbalíme a zajistíme, že můžeme spouštět program `oc` (OpenShift Client).

Pro spuštění je nutné mít nainstalován docker s nastaveným parametrem  `--insecure-registry`.

### Instalace docker a socat

```
yum -y install docker socat
service docker start
docker ps
```

Upravíme konfiguraci dockeru

```
vim /etc/sysconfig/docker #přidat --insecure-registry 172.30.0.0/16
service docker restart
```

### První spuštění clusteru

Ke spuštění OpenShift clusteru použijeme příkaz `oc cluster up`

```
# oc cluster up
-- Checking OpenShift client ... OK
-- Checking Docker client ... OK
-- Checking Docker version ... OK
-- Checking for existing OpenShift container ... OK
-- Checking for openshift/origin:v1.4.1 image ... 
   Pulling image openshift/origin:v1.4.1
   Pulled 0/3 layers, 3% complete
   Pulled 1/3 layers, 79% complete
   Pulled 2/3 layers, 96% complete
   Pulled 3/3 layers, 100% complete
   Extracting
   Image pull complete
-- Checking Docker daemon configuration ... OK
-- Checking for available ports ... 
   WARNING: Binding DNS on port 8053 instead of 53, which may not be resolvable from all clients.
-- Checking type of volume mount ... 
   Using nsenter mounter for OpenShift volumes
-- Creating host directories ... OK
-- Finding server IP ... 
   Using 10.211.55.5 as the server IP
-- Starting OpenShift container ... 
   Creating initial OpenShift configuration
   Starting OpenShift using container 'origin'
   Waiting for API server to start listening
   OpenShift server started
-- Adding default OAuthClient redirect URIs ... OK
-- Installing registry ... OK
-- Installing router ... OK
-- Importing image streams ... OK
-- Importing templates ... OK
-- Login to server ... OK
-- Creating initial project "myproject" ... OK
-- Removing temporary directory ... OK
-- Server Information ... 
   OpenShift server started.
   The server is accessible via web console at:
       https://10.211.55.5:8443

   You are logged in as:
       User:     developer
       Password: developer

   To login as administrator:
       oc login -u system:admin
```

Teď máme připravný OpenShift. 

## Deployment ukázkové aplikace

Vytvoříme nový projekt

```
oc new-project workshop
```

Vytvoříme aplikaci

```
oc new-app --name=myapp wildfly~https://github.com/openshiftdemos/os-sample-java-web.git   
```
V browseru přistoupíme na *https://ip:84443* a přihlásíme se jako uživatel *developer* s heslem *developer*.
Pomocí webové konzole zkontrolujeme deployovanou aplikaci.
V OpenShfit konzole vyzkoušíme navýšit počet instancí naši aplikace a v terminálu pomocí 

``` 
oc get pods 
```
zkontrolujeme jejich počet.

## Cockpit
Cockpit je web management interface pro správu linux serverů/kuberentes/docker kontejnerů a mnohých dalčích technologií. Provedeme jeho instalaci pomocí:
``` 
yum install -y cockpit cockpit-ws cockpit-shell cockpit-kubernetes cockpit-docker
systemctl enable cockpit.socket
systemctl start cockpit
```

Navštívíme url *ip:9090* a přihlásíme se jako uřivatel root. V liště záložek webové aplikace klikneme na cluster, kde vidíme informace o Kubernetes cluster a Docker kontejnerech.




