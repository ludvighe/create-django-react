# Create django-react integrated app

## Why?

Just for quality of life and for the fun of it.

---

## Requirements (in PATH)

```
python3
pip3
pipenv
django-admin
npm
npx
```

## Use

1. Download or clone repo
2. run create_django_react.sh
3. You're all set!

---

## Resulting project

### Project structure

```
.
├── Pipfile
├── Pipfile.lock
├── api
│   ├── __init__.py
│   ├── admin.py
│   ├── apps.py
│   ├── migrations
│   │   └── __init__.py
│   ├── models.py
│   ├── tests.py
│   └── views.py
├── core
│   ├── __init__.py
│   ├── asgi.py
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
├── db.sqlite3
├── frontend
│   ├── README.md
│   ├── build
│   │   └── ...
│   ├── package-lock.json
│   ├── package.json
│   ├── public
│   │   ├── favicon.ico
│   │   ├── index.html
│   │   ├── logo192.png
│   │   ├── logo512.png
│   │   ├── manifest.json
│   │   └── robots.txt
│   └── src
│       ├── components
│       │   └── pages
│       │       └── home-page
│       │           ├── index.css
│       │           └── index.jsx
│       ├── config.js
│       ├── index.css
│       ├── index.js
│       ├── reportWebVitals.js
│       ├── routes.js
│       └── setupTests.js
└── manage.py
```

### npm packages

```
testing-library/jest-dom
testing-library/react
testing-library/user-event
react
react-dom
react-router-dom
react-scripts
web-vitals
```

### python packages

```
django
```
