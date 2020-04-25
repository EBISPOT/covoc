## Customize Makefile settings for covoc
## 
## If you need to customize your Makefile, make
## changes here rather than in the main Makefile


TEMPLATESDIR=../templates

TEMPLATES=$(patsubst %.tsv, $(TEMPLATESDIR)/%.owl, $(notdir $(wildcard $(TEMPLATESDIR)/*.tsv)))

p:
	echo $(TEMPLATES)

prepare_templates: ../templates/config.txt
	sh ../scripts/download_templates.sh $<
	
components/all_templates.owl: $(TEMPLATES)
	$(ROBOT) merge $(patsubst %, -i %, $^) \
		annotate --ontology-iri $(ONTBASE)/$@ --version-iri $(ONTBASE)/releases/$(TODAY)/$@ \
		--output $@.tmp.owl && mv $@.tmp.owl $@

$(TEMPLATESDIR)/%.owl: $(TEMPLATESDIR)/%.tsv $(SRC)
	$(ROBOT) merge -i $(SRC) template --template $< --output $@ && \
	$(ROBOT) annotate --input $@ --ontology-iri $(ONTBASE)/components/$*.owl -o $@

## For COVOC we override imports altogether by removing post-facto all classes not in the seed.
## 
imports/%_import.owl: mirror/%.owl imports/%_terms_combined.txt
	@if [ $(IMP) = true ]; then $(ROBOT) extract -i $< -T imports/$*_terms_combined.txt --force true --method BOT \
		query --update ../sparql/inject-subset-declaration.ru \
		remove -T imports/$*_terms_combined.txt --select complement --select "classes individuals" \
		annotate --ontology-iri $(ONTBASE)/$@ --version-iri $(ONTBASE)/releases/$(TODAY)/$@ --output $@.tmp.owl && mv $@.tmp.owl $@; fi
.PRECIOUS: imports/%_import.owl

## CLO gets special treatment by getting pruned to only those axioms with CLO ids in it.
imports/clo_import.owl: mirror/clo.owl imports/clo_terms_combined.txt
	@if [ $(IMP) = true ]; then $(ROBOT) extract -i $< -T imports/$*_terms_combined.txt --force true --method BOT \
		remove --base-iri $(URIBASE)"/CLO_" --axioms external --preserve-structure false --trim false \
		query --update ../sparql/inject-subset-declaration.ru \
		remove -T imports/$*_terms_combined.txt --select complement --select "classes individuals" \
		annotate --ontology-iri $(ONTBASE)/$@ --version-iri $(ONTBASE)/releases/$(TODAY)/$@ --output $@.tmp.owl && mv $@.tmp.owl $@; fi
.PRECIOUS: imports/clo_import.owl

#mports/efo_import.owl: mirror/efo.owl imports/efo_terms_combined.txt
#	@if [ $(IMP) = true ]; then $(ROBOT) extract -i $< -T imports/efo_terms_combined.txt --force true --method BOT \
#		remove --base-iri http://www.ebi.ac.uk/efo/EFO_ --axioms external --exclude-term IAO:0000117 --exclude-term IAO:0000119 --preserve-structure false --trim false
#		query --update ../sparql/inject-subset-declaration.ru \
#		remove -T imports/$*_terms_combined.txt --select complement --select "classes individuals" \
#		annotate --ontology-iri $(ONTBASE)/$@ --version-iri $(ONTBASE)/releases/$(TODAY)/$@ --output $@.tmp.owl && mv $@.tmp.owl $@; fi
#.PRECIOUS: imports/efo_import.owl