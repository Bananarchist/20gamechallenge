# Builds elm target optionally with debug and outputs to dist
# Copies changed HTML, CSS and JavaScript files to dist
# Copies other changed assets to dist

# Elm target

ELM_SRC = src/elm
ELM_OUT = dist/js/elm.js
ELM_FLAGS = --optimize

# Assets

ASSETS_SRC = assets
ASSETS_OUT = dist/assets

# HTML, CSS and JavaScript

HTML_SRC = src/html
CSS_SRC = src/css
JS_SRC = src/js

dist_dir:
	echo "Creating dist directory"
	mkdir -p dist/js 
	mkdir -p dist/assets

elm.js: dist_dir
	elm make $(ELM_SRC)/Main.elm --output=$(ELM_OUT)

elm-debug.js: dist_dir
	elm make $(ELM_SRC)/Main.elm --output=$(ELM_OUT) --debug

index.html: dist_dir
	echo "Installing html"
	cp $(HTML_SRC)/index.html dist/index.html

index.css: dist_dir
	echo "Installing css"
	cp $(CSS_SRC)/index.css dist/index.css

js_files: dist_dir 
	echo "Installing js"
	cp $(wildcard $(JS_SRC)/*.js) dist/js/

assets: dist_dir
	echo "Copying assets"
	-cp -r $(ASSETS_SRC)/* $(ASSETS_OUT)

all: dist_dir elm.js index.html index.css js_files assets
debug: dist_dir elm-debug.js index.html index.css js_files assets

.PHONY: clean 
clean:
	echo "Removing all built files"
	rm -rf dist/*
	rmdir dist


