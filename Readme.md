# terraforming snowflake

https://quickstarts.snowflake.com/guide/terraforming_snowflake/index.html

```
openssl genrsa -out ~/.ssh/snowflake_tf_snow_key 4096
openssl rsa -in snowflake_tf_snow_key -pubout -out ~/.ssh/snowflake_tf_snow_key.pub
```

```
$ export SNOWFLAKE_USER="tf-snow"
$ export SNOWFLAKE_PRIVATE_KEY_PATH="~/.ssh/snowflake_tf_snow_key"
$ export SNOWFLAKE_ACCOUNT="YOUR_ACCOUNT_LOCATOR"
$ export SNOWFLAKE_REGION="YOUR_REGION_HERE"
```

```
$ touch main.tf # init terraform
$ touch .gitignore # to exclude terraform files
$ terraform init
```