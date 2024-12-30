#import "@preview/unofficial-hka-thesis:1.0.0": *
#import "abbreviations.typ": abbreviations
#import "settings/metadata.typ": *
#import "settings/settings.typ": *
#import "@preview/glossarium:0.5.1": make-glossary

#show: make-glossary

#preface(
  settings: settings,
  degree: degree,
  program: program,
  title: titleEnglish,
  subtitle: subtitleEnglish,
  author: author,
  matriculationNumber: matriculationNumber,
  placeOfWork: placeOfWork,
  supervisor: supervisor,
  advisor: advisor,
  startDate: startDate,
  submissionDate: submissionDate,
)

// Citations - applied here so that you are able to use a local CSL file to define the citation style
#set cite(style: settings.citationStyle)

// Statutory Declaration
#include "supplementary/statutoryDeclaration.typ"
#pagebreak()

// Abstract
#include "supplementary/abstract.typ"
#pagebreak()

// Abstract German
#include "supplementary/abstractGerman.typ"
#pagebreak()

#listings(abbreviations: abbreviations)

#show: mainBody.with(
  settings: settings
)

#include "chapters/1_introduction.typ"

#include "chapters/2_foundations.typ"

//Bibliography
#pagebreak()
#bibliography("bibliography/thesis.bib")

//Appendix
#appendix()[
  #include "chapters/A1_Material.typ"

  #include "chapters/A2_Transcripts.typ"
]