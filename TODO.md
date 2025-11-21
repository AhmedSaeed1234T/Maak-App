# TODO: Make Fields Required in engineer_register_screen.dart

## Steps to Complete:
1. Add GlobalKey<FormState> _formKey to the state class.
2. Wrap the Column inside the Card with Form widget using the _formKey.
3. Modify _buildTextField, _buildTextFieldMultiline, and _buildPasswordField methods to accept an optional validator parameter.
4. Add validators to required fields: firstName, lastName, email, mobile, specialization, salary, password, confirmPassword.
5. For email, add email format validation.
6. For confirmPassword, add matching validation with password.
7. Update _registerEngineer method to validate the form before proceeding.
8. Remove the separate password confirmation check in _registerEngineer since it's now handled by validator.
9. Test the validation by attempting to submit with empty required fields.
