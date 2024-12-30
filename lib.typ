#import "modules/titlepage.typ": *
#import "@preview/glossarium:0.5.1": print-glossary, register-glossary

#let in-outline = state("in-outline", false)
#let flex-caption(long, short) = context {
  if in-outline.at(here()) { short } else { long }
}

#let preface(
  settings: ()
) = {
  // Page Setup
  set page(
    margin: (
      left: settings.pageMargins.left, 
      right: settings.pageMargins.right, 
      top: settings.pageMargins.top, 
      bottom: settings.pageMargins.bottom
    ),
    numbering: "I",
    number-align: center
  )
  counter(page).update(2)

  // Body Font Family
  set text(
    font: settings.fontBody, 
    size: settings.fontBodySize, 
    lang: "en"
  )

  show math.equation: set text(weight: 400)

  // Headings
  show heading: set block(
    below: settings.headingsSpacing.below, 
    above: settings.headingsSpacing.above
  )
  show heading: set text(font: settings.fontBody, size: settings.fontHeadingSize)
  set heading(numbering: none)

  // Paragraphs
  set par(leading: settings.distanceBetweenLines, justify: true)

  // Figures
  show figure: set text(size: settings.fontFiguresSubtitleSize)

  //Indentation of Lists
  set list(indent: settings.listIndentation)
  set enum(indent: settings.listIndentation)
}

#let listings(
  abbreviations: ()
) = {
  register-glossary(abbreviations)
  // Enable short captions to omit citations
  show outline: it => {
      in-outline.update(true)
      it
      in-outline.update(false)
  }

  // Table of Contents
  outline(
    title: {
      heading(outlined: false, "Table of Contents")
      
    },
    target: heading.where(supplement: [Chapter], outlined: true),
    indent: true,
    depth: 3
  )
  
  v(2.4fr)
  pagebreak()

  // List of Figures
  outline(
    title: {
      heading(outlined: false, "List of Figures")
      
    },
    target: figure.where(kind: image),
  )
  pagebreak()

  // List of Tables
  outline(
    title: {
      heading(outlined: false, "List of Tables")
      
    },
    target: figure.where(kind: table)
  )
  pagebreak()

  // List of Listings
  outline(
    title: {
      heading(outlined: false, "List of Listings")
      
    },
    target: figure.where(kind: raw)
  )
  pagebreak()

  // List of Abbreviations
  heading(outlined: false)[List of Abbreviations]
  
  print-glossary(
    abbreviations,
    show-all: false,
    disable-back-references: true,
  )
}

#let mainBody(
  settings: (),
  body
) = {
  // Main Body
  set heading(numbering: settings.headingsNumberingStyle, supplement: [Chapter])
  show heading.where(level: 1): it => {
    if it.numbering == none {
      [
        #it
      ]
    } else {
      [
        #pagebreak()
        #it
      ]
    }

    counter(figure.where(kind: table)).update(0);
    counter(figure.where(kind: image)).update(0);
    counter(figure.where(kind: raw)).update(0);
  }

  set figure(numbering: it => {
    let numberingOfHeading = counter(heading).display();
    let topLevelNumber = numberingOfHeading.slice(0, numberingOfHeading.position("."))
    [#topLevelNumber.#it]
  })
  
  set page(
    // Header with current heading
    header: context {
      let elements = query(
        selector(heading.where(depth: 1)).after(here())
      )

      // Don't show header if a new chapter is starting at the current page
      if elements != () and elements.first().location().page() == here().page() and elements.first().depth == 1 {
          return;
      }

      let displayHeading
      let displayNumbering
      let element
      elements = query(selector(heading).after(here()))
      if elements != () and elements.first().location().page() == here().page() {
        element = elements.first()
        if element.has("numbering") and element.numbering != none {
          displayNumbering = numbering(element.numbering, ..counter(heading).at(element.location()))
        } else {
          displayNumbering = numbering(settings.headingsNumberingStyle, ..counter(heading).at(element.location()))
        }

        displayHeading = element.body
      } else {
        // Otherwise take the next heading backwards
        elements = query(
          heading.where().before(here())
        )
        if elements != () {
          element = elements.last()
          if element.has("numbering") and element.numbering != none {
            displayNumbering = numbering(element.numbering, ..counter(heading).at(element.location()))
          } else {
            displayNumbering = numbering(settings.headingsNumberingStyle, ..counter(heading).at(element.location()))
          }

          displayHeading = element.body
        }
      }

      align(center, displayNumbering + " " + displayHeading)
      line(length: 100%, stroke: (paint: gray))
    },
    
    // Footer with Page Numbering
    footer: context {
      let currentPage = counter(page).display()
      let finalPage = counter(page).final().first()
  
      line(length: 100%, stroke: (paint: gray))
      align(center)[#currentPage / #finalPage]
    }
  )

  set page(
    numbering: "1/1",
    number-align: center,
  )
  counter(page).update(1)
  // Set after header and after all initial pages to just apply it to the acutal content
  set par(spacing: settings.spaceBeforeParagraph)

  // Actual Content
  body
}

// Appendix
#let appendix(body) = {
  pagebreak()
  outline(
    title: {
      heading("Appendix", outlined: true, numbering: none)
    },
    target: heading.where(supplement: [Appendix], outlined: true),
    indent: true,
    depth: 3
  )

  counter(heading).update(0)
  set heading(numbering: "A.1.", supplement: [Appendix])
  show heading: it => {
    let prefixedNumbering;
    if it.level == 1 and it.numbering != none {
      prefixedNumbering = [#it.supplement #counter(heading).display()]
    } else if it.numbering != none {
      prefixedNumbering = [#counter(heading).display()]
    }
    
    block(
      below: 0.85em, 
      above: 1.75em
    )[
      #prefixedNumbering #it.body
    ]
  }

  set figure(numbering: it => {
    let alphabet = ("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z")
    let numberingOfHeading = counter(heading).display();
    let topLevelNumber = numberingOfHeading.slice(0, numberingOfHeading.position("."))
    let index = alphabet.position((el) => { el == topLevelNumber})

    if index == none {
      let numberingToAlphabet = numbering("A", int(topLevelNumber))
      [#numberingToAlphabet.#it]
    } else {
      [#topLevelNumber.#it]
    }
  })

  show heading.where(level: 1): it => {
    if it.numbering == none {
      [
        #it
      ]
    } else {
      [
        #pagebreak()
        #it
      ]
    }

    counter(figure.where(kind: table)).update(0);
    counter(figure.where(kind: image)).update(0);
    counter(figure.where(kind: raw)).update(0);
  }

  body
}

// TODOs
#let todo(body) = [
  #let rblock = block.with(stroke: red, radius: 0.5em, fill: red.lighten(80%))
  #let top-left = place.with(top + left, dx: 1em, dy: -0.35em)
  #block(inset: (top: 0.35em), {
    rblock(width: 100%, inset: 1em, body)
    top-left(rblock(fill: white, outset: 0.25em, text(fill: red)[*TODO*]))
  })
  <todo>
]

#let outline-todos(title: [TODOS]) = {
  heading(numbering: none, outlined: false, title)
  context {
    let queried-todos = query(<todo>)
    let headings = ()
    let last-heading
    for todo in queried-todos {
      let new-last-heading = query(selector(heading).before(todo.location())).last()
      if last-heading != new-last-heading {
        headings.push((heading: new-last-heading, todos: (todo,)))
         last-heading = new-last-heading
      } else {
        headings.last().todos.push(todo)
      }
    }

    for head in headings {
      link(head.heading.location())[
        #numbering(head.heading.numbering, ..counter(heading).at(head.heading.location()))
        #head.heading.body
      ]
      [ ]
      box(width: 1fr, repeat[.])
      [ ]
      [#head.heading.location().page()]

      linebreak()
      pad(left: 1em, head.todos.map((todo) => {
        list.item(link(todo.location(), todo.body.children.at(0).body))
      }).join())
    }
  }
}