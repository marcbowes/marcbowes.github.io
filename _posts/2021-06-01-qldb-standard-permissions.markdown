---
layout: post
title: "QLDB IAM-based permissions"
date: 2021-06-01 13:44:27 -0700
author: Marc
categories: qldb
---

Today, the QLDB team shipped [IAM-based access policy for PartiQL queries and
ledger tables][blog]. This feature is pretty neat, as it significantly improves
control over what users can do and see in your ledger.

Before this feature, access to a QLDB ledger was "all or nothing": if you had
access to a Ledger you could read or write to any table. With today's release
you can make a Ledger in `standard` mode:

{% highlight shell %}
aws qldb create-ledger --name myExampleLedger --permissions-mode STANDARD
{% endhighlight %}

After that, you can create a policy that specifies exactly what a user or role
can do. There are loads of examples [in our documentation][policies], but I want
to highlight the key difference. Let's start with the basic policy:

{% highlight json %}
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "QLDBSendCommandPermission",
            "Effect": "Allow",
            "Action": "qldb:SendCommand",
            "Resource": "arn:aws:qldb:us-east-1:123456789012:ledger/myExampleLedger"
        },
        
    ]
}
{% endhighlight %}

The above policy lets a user connect to a specific ledger. _If_ this was an
`ALLOW_ALL` ledger, that policy would grant full access to all tables. However,
myExampleLedger is using the new permissions mode! Connecting with the above
policy will result in zero effective permissions.

{% highlight json %}
{
    "Sid": "QLDBPartiQLFullPermission",
    "Effect": "Allow",
    "Action": [
        "qldb:PartiQLCreateIndex",
        "qldb:PartiQLDropIndex",
        "qldb:PartiQLCreateTable",
        "qldb:PartiQLDropTable",
        "qldb:PartiQLUndropTable",
        "qldb:PartiQLDelete",
        "qldb:PartiQLInsert",
        "qldb:PartiQLUpdate",
        "qldb:PartiQLSelect",
        "qldb:PartiQLHistoryFunction"
    ],
    "Resource": [
        "arn:aws:qldb:us-east-1:123456789012:ledger/myExampleLedger/table/*",
        "arn:aws:qldb:us-east-1:123456789012:ledger/myExampleLedger/information_schema/user_tables"
    ]
}
{% endhighlight %}

> Note that this is an *additional* statement. The SendCommand access is still
> required.

The above statement gives full access to all tables and effectively returns the
user back to "can do anything" mode. The cool thing is you can now play around
with the set of actions and tables. For example, if you limit the set of actions
to `qldb:PartiQLSelect` then the user would have read only access to all tables.

Limiting actions is pretty straight-forward and can be used to quickly create
safe roles like "read only access" for every day use.

In a future post, I'll talk about limiting access to specific tables and how to
leverage tags to create groups.

[blog]: https://aws.amazon.com/about-aws/whats-new/2021/06/amazon-qldb-supports-iam-based-access-policy-for-partiql-queries-and-ledger-tables/
[policies]: https://docs.aws.amazon.com/qldb/latest/developerguide/security_iam_id-based-policy-examples.html
