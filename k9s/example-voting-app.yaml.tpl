apiVersion: v1
kind: Namespace
metadata:
  name: ${NAMESPACE}

---

apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: db
  name: db
  namespace: ${NAMESPACE}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: db
  template:
    metadata:
      labels:
        app: db
    spec:
      containers:
      - image: postgres:9.4
        name: postgres
        env:
        - name: POSTGRES_USER
          value: postgres
        - name: POSTGRES_PASSWORD
          value: postgres
        ports:
        - containerPort: 5432
          name: postgres
        volumeMounts:
        - mountPath: /var/lib/postgresql/data
          name: db-data
      volumes:
      - name: db-data
        emptyDir: {} 

---

apiVersion: v1
kind: Service
metadata:
  labels:
    app: db
  name: db
  namespace: ${NAMESPACE}
spec:
  type: ClusterIP
  ports:
  - name: "db-service"
    port: 5432
    targetPort: 5432
  selector:
    app: db

---

apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: redis
  name: redis
  namespace: ${NAMESPACE}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - image: redis:alpine
        name: redis
        ports:
        - containerPort: 6379
          name: redis
        volumeMounts:
        - mountPath: /data
          name: redis-data
      volumes:
      - name: redis-data
        emptyDir: {} 

---

apiVersion: v1
kind: Service
metadata:
  labels:
    app: redis
  name: redis
  namespace: ${NAMESPACE}
spec:
  type: ClusterIP
  ports:
  - name: "redis-service"
    port: 6379
    targetPort: 6379
  selector:
    app: redis
  
---

apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: result
  name: result
  namespace: ${NAMESPACE}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: result
  template:
    metadata:
      labels:
        app: result
    spec:
      containers:
      - image: dockersamples/examplevotingapp_result:before
        name: result
        ports:
        - containerPort: 80
          name: result
  
---

apiVersion: v1
kind: Service
metadata:
  labels:
    app: result
  name: result
  namespace: ${NAMESPACE}
spec:
  type: NodePort
  ports:
  - name: "result-service"
    port: 5001
    targetPort: 80
    nodePort: ${RESULT_SERVICE_PORT}
  selector:
    app: result
  
---

apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: vote
  name: vote
  namespace: ${NAMESPACE}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: vote
  template:
    metadata:
      labels:
        app: vote
    spec:
      containers:
      - image: dockersamples/examplevotingapp_vote:before
        name: vote
        ports:
        - containerPort: 80
          name: vote
  
---

apiVersion: v1
kind: Namespace
metadata:
  name: vote
  
  
---

apiVersion: v1
kind: Service
metadata:
  labels:
    app: vote
  name: vote
  namespace: ${NAMESPACE}
spec:
  type: NodePort
  ports:
  - name: "vote-service"
    port: 5000
    targetPort: 80
    nodePort: ${VOTE_SERVICE_PORT}
  selector:
    app: vote
  
  
---

apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: worker
  name: worker
  namespace: ${NAMESPACE}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: worker
  template:
    metadata:
      labels:
        app: worker
    spec:
      containers:
      - image: dockersamples/examplevotingapp_worker
        name: worker
