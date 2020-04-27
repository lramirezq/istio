echo "Este script creara una imagen"
version=$1

rm -rf Dockerfile
rm -rf Deployment.yaml
rm -rf Service.yaml

#crear version
mvn clean compile package

cat << EOF > Dockerfile
from java:8
RUN mkdir -p  /opt/3htp
ADD ./target/demo-istio-0.0.1-SNAPSHOT.jar /opt/3htp/
WORKDIR /opt/3htp/ented.
EOF

id_image=$(docker build -t $version . | grep built | awk '{ print $3 }' )
echo "la version es $id_image"

docker images | grep $id_image

#tag
docker tag $id_image lramirezq/istio-ppt:$version

#push
docker push lramirezq/istio-ppt:$version

#create deployment K8s
vs=$(echo "$version" | tr -d '.')
cat << EOF > Deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
  labels:
    app: microservicio-lrq
  name: microservicio-lrq-$version
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: microservicio-lrq
  template:
    metadata:
      labels:
        app: microservicio-lrq
        version: "$vs"
    spec:
      containers:
      - args:
        - java -jar /opt/3htp/demo-istio-0.0.1-SNAPSHOT.jar
        command:
        - /bin/bash
        - -c
        image: lramirezq/istio-ppt:$version
        imagePullPolicy: IfNotPresent
        name: microservicio-lrq
        ports:
        - containerPort: 8080
          protocol: TCP
      restartPolicy: Always
      schedulerName: default-scheduler
EOF

cat Deployment.yaml
kubectl apply -f Deployment.yaml
kubectl label deploy microservicio-lrq-$version version=$version

kubectl get deploy --selector=version=$version 
kubectl get po 


#create Service K8s

cat << EOF > Service.yaml
apiVersion: v1
kind: Service
metadata:
  name: lrq
  labels:
    app: microservicio-lrq
    service: svc-microservicio-lrq
spec:
  ports:
  - port: 8080
    name: http
  selector:
    app: microservicio-lrq
EOF

kubectl apply -f Service.yaml
echo "$version Instalada en Namespace lramirez"