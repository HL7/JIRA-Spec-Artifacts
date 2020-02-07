# JIRA-Spec-Artifacts
This project manages the artifacts, pages and other lists associated with all HL7 projects managed through JIRA feedback projects

Source content is found in the 'xml' folder:
* The ''_workgroups.xml'' file maintains the lists of all work groups that can take responsibility for JIRA feedback items
* The ''_families.xml'' file maintains the list of product families.  The 'key' attribute must match the JIRA project prefix for that family
* The ''SPECS_???.xml'' files list what specifications are part of a product family.  
** This file should only be edited by the product director responsible the family
** The ??? portion of the filename must match one of the keys specified in ''_families.xml'' - and one of these files MUST exist for each family
* The remaining files (e.g. ''FHIR-core.xml'') document the artifacts and pages associated with each specification
** The filenames have the format [family key]-[specification-key].xml
** These files should be maintained in a manner consistent with the artifacts and pages defined in the specification.
** For some specifications, alignment will be checked as part of the specification publication process
** Specification files are maintained independently rather than as part of the SPECS files to allow independent maintenance

Each type of XML file has a corresponding schema in the ''schemas'' folder.  The ''_workgroups.xml'' file is also converted to a schema to aid validation

The json files used by the Jira nFeed plugin to manage dropdowns are auto-generated into the json folder.
There is one file for each product family plus a single "combined" file that covers all specifications and is used by the ballot projects
None of these files should be manipulated directly as they'll be overwritten.
An additional file called SPECS.xml is used to help ensure that keys aren't accidentally deleted or changed

NOTE: any key used by any Jira tracker items must NEVER be removed or changed.  Removal of other keys should be handled by an administrator

## Building
This JSON artifacts of this project can be built manually on the command line like this:
```sh
bash $> java -jar ./tools/ant/ant-launcher.jar
Buildfile: ~/code/JIRA-Spec-Artifacts/build.xml

validate:
     [xslt] Processing ~/code/JIRA-Spec-Artifacts/xml/_workgroups.xml to ~/code/JIRA-Spec-Artifacts/schemas/workgroups.xsd
     [xslt] Loading stylesheet ~/code/JIRA-Spec-Artifacts/tools/buildWGschema.xslt

genJson:
    [mkdir] Created dir: ~/code/JIRA-Spec-Artifacts/json
    [mkdir] Created dir: ~/code/JIRA-Spec-Artifacts/tools/temp
     [xslt] Processing ~/code/JIRA-Spec-Artifacts/xml/_families.xml to ~/code/JIRA-Spec-Artifacts/json/families.json
     [xslt] Loading stylesheet ~/code/JIRA-Spec-Artifacts/tools/xmlToJson.xslt
     [xslt] Processing ~/code/JIRA-Spec-Artifacts/xml/_workgroups.xml to ~/code/JIRA-Spec-Artifacts/json/workgroups.json
     [xslt] Loading stylesheet ~/code/JIRA-Spec-Artifacts/tools/xmlToJson.xslt
      [get] Getting: https://hl7.github.io/JIRA-Spec-Artifacts/SPECS.xml
      [get] To: ~/code/JIRA-Spec-Artifacts/tools/temp/SPECS.xml
     [xslt] Processing ~/code/JIRA-Spec-Artifacts/xml/_families.xml to ~/code/JIRA-Spec-Artifacts/json/SPECS.json
     [xslt] Loading stylesheet ~/code/JIRA-Spec-Artifacts/tools/buildSpecJSON.xslt

test:

BUILD SUCCESSFUL
Total time: 2 seconds
bash $> 
```

## Automatic Deployments
There is a GitHub Action defined to automatically build and deploy the JSON files from the `master` repo into the `gh-pages` branch upon every commit to the `master` branch.  For this to work, a deployment ssh key has been defined and added to the repository settings.  You must be an admin of the repo to make changes to this key.
