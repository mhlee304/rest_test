rest_test
=====

An OTP application

POST

curl -vX POST -H 'Content-Type:application/json' http://localhost:8080/start_registration -d @data.json -i

GET

curl -H “Accept: get/json” http://localhost:8080/finish_registration -i

Build
-----

    $ rebar3 compile
