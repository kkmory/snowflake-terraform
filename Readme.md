# terraforming snowflake

https://quickstarts.snowflake.com/guide/terraforming_snowflake/index.html

```
$ openssl genrsa -out ~/.ssh/snowflake_tf_snow_key 4096
$ openssl rsa -in snowflake_tf_snow_key -pubout -out ~/.ssh/snowflake_tf_snow_key.pub
# create user having this pubkey at snowflake worksheet
```

```
$ export SNOWFLAKE_USER="tf-snow"
$ export SNOWFLAKE_PRIVATE_KEY_PATH="~/.ssh/snowflake_tf_snow_key"
$ export SNOWFLAKE_ACCOUNT="YOUR_ACCOUNT_LOCATOR"
$ export SNOWFLAKE_REGION="ap-northeast-1.aws"
```

```
$ terraform init
$ tarraform plan
$ terraform apply
```
