# Configuring templates

The COVOC vocabulary pipeline is based on Google sheets for curation and ROBOT for
template compilation. This is how its done:

1. Publish a particular sheet on Google sheets (File > Publish on web). In the publishing dialog select the sheet you want to publish and as the file type TSV (not: Web page). Copy the url to the sheet.
2. Go to config.txt and and a row by giving the sheet name, for example `organism` and the url copied in the last step. Use the pipe symbol ('|') to separate the two.
3. Important: Make sure there is exactly one empty row in the end of the file.

When this is done, the release manager will run 

```
cd src/ontology
sh run.sh make prepare_templates
```

To download the pattern files from Gsheets into the template directory. The usual release pipeline will then build and merge all the templates into a single component (`src/ontology/components/all_templates.owl`). The rest of the release pipeline works as usual. 

More in `src/ontology/README-editors.md`