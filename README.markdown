# Steam Donkey

![steam-donkey]

Tools and scripts for building and managing infrastructure on AWS.

## Commands

### donkey ec2 list [--fields] [--raw]

Find all instances and display their name, running state, and ssh key name

```
$ donkey ec2 list --fields 'Name,State,KeyName'
```

Find all running instances

```
$ donkey ec2 list --fields 'Name,State=running,KeyName'
```

Find all running instances that use a key beginning with `dev-`

```
$ donkey ec2 list --fields 'Name,State=running,KeyName=?/^dev/'
```

Find all running instances that _don't_ use a key beginning with `dev-`

```
$ donkey ec2 list --fields 'Name,State=running,KeyName=!/^dev-/'
```



```
$ donkey ec2 list --fields 'PublicIpAddress,State=running,KeyName=?/^dev$/' --raw | cut -f1 -d,
```



[steam-donkey]: https://upload.wikimedia.org/wikipedia/commons/f/fe/Dolbeer-patent-1.jpg "Steam Donkey"



