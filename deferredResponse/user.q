/ q user.q

h: hopen 8080;

sendQuery: {[query] h query };

/
processes:
- rdb
- gateway
- user1
- user2

```q
user1.q) sendQuery (`request; `rdb; "3#trade")
user2.q) sendQuery (`request; `rdb; "3#quote")
```