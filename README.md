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