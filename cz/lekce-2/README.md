# Lekce 2

* [Persistent Volumes](#Persistent volumes)
* [Image streams](#Image streams)
* [Source to Image (s2i)](#Source to Image (s2i))
* [Šablony - (Template)](#Šablony - (Template))

## Persistent volumes

## Image Streams

## Source to Image (s2i)

## Šablony - (Template)
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
