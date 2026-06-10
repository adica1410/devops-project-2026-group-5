Script-2:
## Load testing

#Following command installs #loadtest package to perform load testing on the application
#Prerequisites are mentioned in the resources section

npm install -g loadtest

#Following command performs load testing on the given URL. replace the URL with Loadbalancer (or Public IP of EC2 instance)
# Press ctrl +C to stop the script

loadtest --rps 1000  -c 500 -k <<ELB URL>>