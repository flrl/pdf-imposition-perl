package PDF::Imposition::Schema1repeat2bottom;
use strict;
use warnings;
use Moo;
with "PDF::Imposition::Schema";

=head1 NAME

PDF::Imposition::Schema1repeat2bottom - put two identical pages one on the top of each other.

=head1 SYNOPSIS

    use PDF::Imposition::Schema1repeat2bottom;
    my $imposer = PDF::Imposition::Schema1repeat2bottom->new(
                                                          file => "test.pdf",
                                                          output => "out.pdf",
                                                         );
    $imposer->impose;

=head1 SCHEMA EXPLANATION

     +-----+    +-----+
     |     |    |     |
     |  1  |    |  2  |
     |     |    |     |
     +-----+    +-----+
     |     |    |     |
     | r1  |    | r2  |
     |     |    |     |
     +-----+    +-----+

The same logical page is inserted twice, one on the top of each other,
on the same sheet, with the bottom copy rotated 180 degrees.

=cut


sub _do_impose {
    my $self = shift;
    $self->out_pdf_obj->mediabox(
                                 $self->orig_width,
                                 $self->orig_height * 2,
                                );
    foreach my $pageno (1..$self->total_pages) {
        my ($page, $gfx, $chunk);
        $page = $self->out_pdf_obj->page;
        $gfx = $page->gfx;

        # right way up copy at top
        $chunk = $self->get_imported_page($pageno);
        $gfx->formimage($chunk, 0, $self->orig_height) if $chunk;

        # rotated copy at bottom
        $chunk = $self->get_imported_page($pageno);
        $gfx->transform(
            -translate => [$self->orig_width,
                           $self->orig_height],
            -rotate => 180,
        );
        $gfx->formimage($chunk, 0, 0) if $chunk;
    }
}

=head1 INTERNALS

=head2 cropmarks_options

Set twoside to false.

=cut

sub cropmarks_options {
    my %options = (
                   top => 1,
                   bottom => 1,
                   inner => 1,
                   outer => 1,
                   # no shifting need
                   twoside => 0,
                   signature => 0,
                  );
    return %options;
}


1;
