rest_test
=====

An OTP application

POST

curl -vX POST -H 'Content-Type:application/json' http://localhost:8080/start_registration -d @data.json -i

GET

curl -H “Accept: get/json” http://localhost:8080/finish_registration -i

Build
-----

    $ rebar3 shell
    In seperate shell to start registration do...
    curl -vX POST -H 'Content-Type:application/json' http://localhost:8080/start_registration -d @userdata.json -i

    
Test
-----
Start Registration / Enroll Tests

See values in Mnesia table called "project":
ets:tab2list(project).



