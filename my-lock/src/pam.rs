use std::ffi::{OsStr, OsString};

use nonstick::{
    AuthnFlags, ConversationAdapter, Result as PamResult, Transaction, TransactionBuilder
};

struct UsernamePassConvo {
    username: String,
    password: String,
}

impl ConversationAdapter for UsernamePassConvo {
    fn prompt(&self, _request: impl AsRef<OsStr>) -> PamResult<OsString> {
        Ok(OsString::from(&self.username))
    }

    fn masked_prompt(&self, _request: impl AsRef<OsStr>) -> PamResult<OsString> {
        Ok(OsString::from(&self.password))
    }

    fn error_msg(&self, _message: impl AsRef<OsStr>) {
        // Normally you would want to display this to the user somehow.
        // In this case, we're just ignoring it.
    }

    fn info_msg(&self, _message: impl AsRef<OsStr>) {
        // ibid.
    }
}


pub fn authenticate(username: &str, password: &str) -> PamResult<()> {
    let user_pass = UsernamePassConvo {
        username: username.into(),
        password: password.into(),
    };

    let mut txn = TransactionBuilder::new_with_service("login")
        .username(username)
        .build(user_pass.into_conversation())?;
    // If authentication fails, this will return an error.
    // We immediately give up rather than re-prompting the user.
    txn.authenticate(AuthnFlags::empty())?;
    txn.account_management(AuthnFlags::empty())?;
    Ok(())
}
