helm install -f values/redis-values.yaml redis-cart charts/redis

helm install -f values/emailservice-values.yaml emailservice charts/microsvc
helm install -f values/cartservice-values.yaml cartservice charts/microsvc
helm install -f values/currencyservice-values.yaml currencyservice charts/microsvc
helm install -f values/paymentservice-values.yaml paymentservice charts/microsvc
helm install -f values/recommendationservice-values.yaml recommendationservice charts/microsvc
helm install -f values/productcatalogservice-values.yaml productcatalogservice charts/microsvc
helm install -f values/shippingservice-values.yaml shippingservice charts/microsvc
helm install -f values/adservice-values.yaml adservice charts/microsvc
helm install -f values/checkoutservice-values.yaml checkoutservice charts/microsvc
helm install -f values/frontend-values.yaml frontend charts/microsvc