(define mec (read-color-image "mec.ppm"))
mec
(load "histogram.scm")
(plot-color-histogram mec)