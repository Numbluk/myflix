shared_examples 'require_sign_in' do
  it 'redirects to the front page' do
    clear_current_user
    action
    expect(response).to redirect_to sign_in_path
  end
end

shared_examples 'generate_token' do
  it 'generates a token' do

  end
end
