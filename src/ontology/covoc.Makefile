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
		remove --base-iri $(URIBASE)"/$(shell echo $* | tr a-z A-Z)_" --axioms external --preserve-structure false --trim false \
		query --update ../sparql/inject-subset-declaration.ru \
		remove -T imports/$*_terms_combined.txt --select complement --select "classes individuals" \
		remove --term rdfs:seeAlso --term rdfs:comment --select "annotation-properties" \
		query --update ../sparql/remove_chinese.ru  \
		annotate --ontology-iri $(ONTBASE)/$@ --version-iri $(ONTBASE)/releases/$(TODAY)/$@ --output $@.tmp.owl && mv $@.tmp.owl $@; fi
.PRECIOUS: imports/%_import.owl

# EFO needs special treatment because of non-obo IRI (http://www.ebi.ac.uk/efo/EFO_)
imports/efo_import.owl: mirror/efo.owl imports/efo_terms_combined.txt
	@if [ $(IMP) = true ]; then $(ROBOT) extract -i $< -T imports/efo_terms_combined.txt --force true --method BOT \
		remove --base-iri http://www.ebi.ac.uk/efo/EFO_ --axioms external --exclude-term IAO:0000117 --exclude-term IAO:0000119 --preserve-structure false --trim false \
		query --update ../sparql/inject-subset-declaration.ru \
		remove -T imports/efo_terms_combined.txt --select complement --select "classes individuals" \
		annotate --ontology-iri $(ONTBASE)/$@ --version-iri $(ONTBASE)/releases/$(TODAY)/$@ --output $@.tmp.owl && mv $@.tmp.owl $@; fi
.PRECIOUS: imports/efo_import.owl
	
# NCBITAXON gets special treatment because of non-capitalised IRI (http://purl.obolibrary.org/obo/NCBITaxon_2697049s)
# On second thought, maybe that is not necessary. Experiment with removing this again

imports/ncbitaxon_import.owl: mirror/ncbitaxon.owl imports/ncbitaxon_terms_combined.txt
	@if [ $(IMP) = true ]; then $(ROBOT) extract -i $< -T imports/ncbitaxon_terms_combined.txt --force true --method BOT \
		remove --base-iri $(URIBASE)"/NCBITaxon_" --axioms external --preserve-structure false --trim false \
		query --update ../sparql/inject-subset-declaration.ru \
		remove -T imports/ncbitaxon_terms_combined.txt --select complement --select "classes individuals" \
		annotate --ontology-iri $(ONTBASE)/$@ --version-iri $(ONTBASE)/releases/$(TODAY)/$@ --output $@.tmp.owl && mv $@.tmp.owl $@; fi
.PRECIOUS: imports/ncbitaxon_import.owl
