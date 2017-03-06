set -e
mkdir -p $HOME/.config/matplotlib
echo backend\:\ agg >> $HOME/.config/matplotlib/matplotlibrc
export MATPLOTLIBRC=$HOME/.config/matplotlib
mkdir -p $HOME/mosek
openssl aes-256-cbc -K $encrypted_b279d3ed6718_key -iv $encrypted_b279d3ed6718_iv -in $TRAVIS_BUILD_DIR/lic.enc -out $HOME/mosek/mosek.lic -d
pip install -r requirements.txt jupyter
set +e
