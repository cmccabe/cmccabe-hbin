all:		backport_review/backport_review

backport_review/backport_review: backport_review/backport_review.go backport_review/bitset.go backport_review/column_formatter.go backport_review/git.go
	cd backport_review && go build *.go

clean:
	rm -f backport_review/backport_review
