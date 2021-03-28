# Url Shortener

## About
- this project is an enhancement on [hlappa/url-shortener](https://gitlab.com/hlappa/url-shortener)
	* improve the create link flow, to return the same short url for same input
	* in memory cache for accessing original links from shortened url

To fire up the project:

```
$ docker-compose build
$ docker-compose run web mix ecto.create
$ docker-compose up
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
