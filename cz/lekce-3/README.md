# Lekce 3

* Pipelines
* Metriky
* Logování

## Pipelines

K této části opět potřebujeme běžící OpenShift

```
oc cluster up
```

Dalším krokem bude spuštění Jenkinsu

```
oc new-app jenkins-ephemeral
```

Tento příkaz spustí 2 pody - Jenkins Master a Jenkins JNLP a exportuje URL https://jenkins-myproject....

Jakmile pody nastartují, můžete se do Jenkinsu zkusit přihlásit. Jenkins je nakonfigurovaný, aby vaužíval OpenShift OAuth, 
takže není třeba vytvářet účty, přihlásíte se jednoduše pomocí uživatele `developer`.

```
oc get routes jenkins --output jsonpath={.spec.host}
```

Jelikož buildíme vert.x aplikaci, potřebujeme vertx-s2i ImageStream (který není standardní součástí OpenShiftu)

```
oc create -f https://raw.githubusercontent.com/vert-x3/vertx-openshift-s2i/master/vertx-s2i-all.json
```

Jakmile build vertx-s2i image doběhne, budeme potřebovat naši ukázkovou aplikaci

```
oc process -f https://raw.githubusercontent.com/vpavlin/vertx-demo/master/openshift/template-myapp.yaml | oc apply -f -
```

Po aplikování tohoto templatu se v OpenShiftu objeví DeploymentConfig, Service a Route pro vertx-helloworld aplikaci, ImageStream pro aplikační image, s2i build a Pipeline build

Spustíme build

```
oc start-build myapp-pipeline
```

Tohle už z příkazového řádku asi nezvládneme, takže si (pokud nemáte) otevřete OpenShift Consoli a Jenkins a zamiřte do `Builds > Pipelines`, 
případně se proklikejte k jobu v Jenkinsu

Pokud vše dopadne dobře, měl by úspěšně proběhnout build 

```
oc get builds | grep Source | grep myapp
```

a deployment

```
oc get rc | grep myapp
```

URL aplikace pak jednoduše zjistíme pomocí

```
oc get routes myapp --output jsonpath={.spec.host}
```

Pokud se pokusíte přistoupit přímo na URL, dostanete chybu. Pokud chceme získat očekávaný Hello World, musíme zkusit něco jako

```
curl http://$(oc get routes myapp --output jsonpath={.spec.host})/greeting?name=OpenShift
```

## Spuštění buildu pomocí webhooku

Spouštění buildů je možné automatizovat pomocí webhooků. Nejprve je třeba získat URL webooku

```
oc describe bc myapp-pipeline | grep webhooks | grep generic | sed 's/.*URL:\s*//'
```

Dalším krokem (pro spuštění buildu) je vytvoření POST dotazu

```
curl -X POST $(oc cluster status | grep URL: | sed 's/.*URL:\s//')/oapi/v1/namespaces/myproject/buildconfigs/myapp-pipeline/webhooks/secret101/generic
```

## Rozšiřitelnost

Jenkinsfile je Groovy skript

* https://github.com/vpavlin/vertx-demo/blob/master/Jenkinsfile

Ale jde to i komplikovaněji - https://fabric8.io/

* https://github.com/vpavlin/vertx-web/blob/master/Jenkinsfile
* https://github.com/fabric8io/fabric8-pipeline-library



# Metriky
Metriky v openshift jsou sbírány pomocí Heapster (který čte metriky ze /stats REST API), ukládány jsou pomocí Hawkular a cassandry.
Metriky si na našem vývojovém clusteru nejsnadněji zpřístupníme pomocí
```
oc cluster up --metrics
```
Poté v OpenShift Origin konzole přisotupíme do projektu Opensfhit-infra, kde uvidíme deployované komponenty a router url pro přístup do hawkular. 

# Logování

Centrální logování je kritickou komponenout jakéhokoliv clusteru. V OpenShift Origin je integrován ELK(přesněji EFK) stack. Pro vyzkoušení logování spustíme:
```
oc cluster up --logging
```
Poté v OpenShift origin navstívíme projekt logging, kde uvídíme deployované komponenty a můžeme přistoupit do konzole Kibany. V OpenShift jsou logy separované dle projektu(namespace) a utentizace/autorizace je integrována pomocí OAUTH2.
