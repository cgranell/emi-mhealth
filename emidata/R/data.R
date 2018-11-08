
#' Papers
#'
#' List of selected papers included in the review (N=136).
#'
#' @source References retrieved from scientific databases such as Scopus, Web of Science, and PubMed.
#' @format A data frame with nine variables:
#' \describe{
#'   \item{\code{filename}}{Full filename of the paper.}
#'   \item{\code{id}}{A unique identifier.}
#'   \item{\code{type}}{Article or InProceedings , same syntax as bibtex.}
#'   \item{\code{title}}{Title of the paper.}
#'   \item{\code{abstract}}{Asbtract of the paper.}
#'   \item{\code{journal}}{Name of the jpurnal if journal article, otherwise NA if conference paper.}
#'   \item{\code{author}}{List of authors separated y "and"}
#'   \item{\code{year}}{Publishing year of the paper, a value between 2013 and 2018}
#'   \item{\code{keywords}}{List of keyworkd separated by coma, otherwise NA}
#'
#' }
#' @examples
#' \dontrun{
#'   papers
#'   }
"papers"
