# web-app-https-starter

Quickly/easily start a tunnel and serve a local folder with valid HTTPS for development

Example:
````
docker run -it --rm -v `pwd`/dist:/www cohunter/web-app-https-starter
````

This would serve the files in ./dist on a URL with valid HTTPS for testing/development.
