;
;          histogram.scm -- Lance R. Williams, Feb. 7, 2005.
;
;            Copyright 2005 University of New Mexico.
;                      All rights reserved.
;
;     Permission to copy and modify this software and its documen-
;     tation only for internal use in your organization is hereby
;     granted, provided that this notice is retained thereon and
;     on all copies.  UNM makes no representations as to the sui-
;     tability and operability of this software for any purpose.
;     It is provided "as is" without express or implied warranty.
;
;     UNM DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
;     INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FIT-
;     NESS.  IN NO EVENT SHALL UNM BE LIABLE FOR ANY SPECIAL,
;     INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY OTHER DAMAGES WHAT-
;     SOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER
;     IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS
;     ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PER-
;     FORMANCE OF THIS SOFTWARE.
;
;     No other rights, including, for example, the right to redis-
;     tribute this software and its documentation or the right to
;     prepare derivative works, are granted unless specifically
;     provided in a separate license agreement.
;
;     Copyright 2005, University of New Mexico. All rights
;     reserved.

(define (vector-increment! v i)
  (vector-set! v i (+ (vector-ref v i) 1)))

(define (histogram A)
  (let ((maximum (floor (fold max A)))
        (m (image-rows A))
        (n (image-cols A)))
    (let ((h (make-vector (+ maximum 1))))
      (do ((i 0 (+ i 1))) ((= i m) h)
	(do ((j 0 (+ j 1))) ((= j n))
	  (vector-increment! h (image-ref A i j)))))))

(define (plot-histogram A)
  (let ((maximum (floor (fold max A)))
        (h (histogram A))
        (output-port (open-output-file "histogram.txt")))
    (fprintf output-port "plot [0:%g] '-' title 'intensity' with lines\n" maximum)
    (do ((i 0 (+ i 1))) ((= i maximum))
      (fprintf output-port "%g\n" (vector-ref h i)))
    (fprintf output-port "exit\n")
    (close-output-port output-port)
    (system "gnuplot -persist < histogram.txt &")
    (void)))

(define (plot-histograms A B)
  (let ((maxA (floor (fold max A)))
        (maxB (floor (fold max B)))
        (hA (histogram A))
        (hB (histogram B)))
    (let ((output-port (open-output-file "histogram.txt")))
      (fprintf output-port "plot [0:%g]" (max maxA maxB))
      (fprintf output-port "'image1.dat' title 'image 1' with lines,")
      (fprintf output-port "'image2.dat' title 'image 2' with lines\n")
      (fprintf output-port "exit\n")
      (close-output-port output-port))
    (let ((output-port (open-output-file "image1.dat")))
      (do ((i 0 (+ i 1))) ((= i maxA))
	(fprintf output-port "%g\n" (vector-ref hA i)))
      (close-output-port output-port))
    (let ((output-port (open-output-file "image2.dat")))
      (do ((i 0 (+ i 1))) ((= i maxB))
	(fprintf output-port "%g\n" (vector-ref hB i)))
      (close-output-port output-port)))
  (system "gnuplot -persist < histogram.txt &")
  (void))

(define (plot-color-histogram A)
  (name-parts-of (color-image->rgb A) (R G B)
    (let ((maxR (floor (fold max R)))
	  (maxG (floor (fold max G)))
	  (maxB (floor (fold max B)))
	  (hR (histogram R))
	  (hG (histogram G))
	  (hB (histogram B)))
      (let ((output-port (open-output-file "histogram.txt")))
	(fprintf output-port "plot [0:%g]" (max maxR maxG maxB))
	(fprintf output-port "'red.dat' title 'red' with lines,")
	(fprintf output-port "'green.dat' title 'green' with lines,")
	(fprintf output-port "'blue.dat' title 'blue' with lines\n")
	(fprintf output-port "exit\n")
	(close-output-port output-port))
      (let ((output-port (open-output-file "red.dat")))
	(do ((i 0 (+ i 1))) ((= i maxR))
	  (fprintf output-port "%g\n" (vector-ref hR i)))
	(close-output-port output-port))
      (let ((output-port (open-output-file "green.dat")))
	(do ((i 0 (+ i 1))) ((= i maxG))
	  (fprintf output-port "%g\n" (vector-ref hG i)))
	(close-output-port output-port))
      (let ((output-port (open-output-file "blue.dat")))
	(do ((i 0 (+ i 1))) ((= i maxB))
	  (fprintf output-port "%g\n" (vector-ref hB i)))
	(close-output-port output-port))
      (system "gnuplot -persist < histogram.txt &")
      (void))))
