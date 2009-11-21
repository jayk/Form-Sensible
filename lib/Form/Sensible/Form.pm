package Form::Sensible::Form;

use Moose;

## a form is a collection of fields. Different form types will work differently.

## the Concept basically follows a flow:
## Form is created.
## Fields are placed into the Form
## Form is rendered
## user takes action - filling in fields, etc.
## user indicates form is complete (submit) or cancelled.
## If cancelled, form triggers cancel action.

## if submitted - form calls validators in turn on each of it's fields (and finally a
##               'last step' validation that runs against all fields, if provided.)

## if validation fails - failed_validation action is called - most often re-render of the form with messages.

## if validation succeeds - complete_action is called.


1;