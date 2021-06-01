sass = $(wildcard pile-theme/*.scss)
css = public/css/main.css

$(css): $(sass)
	@echo building css
	sass pile-theme/main.scss assets/css/main.css

all: $(css)
	@echo building all
