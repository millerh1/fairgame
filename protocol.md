Here's how you actually use this.

1. Clone the repo and checkout alpha

```shell
git clone https://github.com/millerh1/fairgame.git
git checkout alpha
```

2. Install dependencies and start pipenv shell

```shell
pipenv install
pipenv shell
```

3. Generate credential configuration and get cat food.
   This step requirest the tester as `config/amazon_aio_conrfig.json`. 
   It should look like this:

```json
{
  "items": [
    {
      "asins": ["B0160U60XO"],
      "min-price": 2,
      "max-price": 6,
      "condition": "New"
    },
    {
      "asins": ["B006JG471M"],
      "min-price": 0,
      "max-price": 5,
      "condition": "New"
    }
  ],
  "amazon_domain": "smile.amazon.com"
}
```

Run this with the following:

```shell
pipenv run python app.py amazon-aio
```

4. Buy proxies from oculus (always look for a recent discount code).
   You will also want to change to password authentication. 
   Then copy the list of proxies to a file `config/proxies/raw_proxies.txt`.
   I usually get 50 release premium datacenter proxies (~90$/month)
   
5. Run the R script to organize them into JSON (may need to install `readr`, `dplyr`, and `jsonlite`)

```shell
Rscript config/proxies/proxy_clean.R config/raw_proxies.txt config/proxies.json
```

6. Download the discord chat exporter [here](https://github.com/Tyrrrz/DiscordChatExporter). 
   And proceed to process it with R using the `discord/process_discord.R` script. 
   This will require manual operation because you will need to sanity check the results - 
   and decide on reasonable prices. Once you are ready, create the final config json file
   by finishing the R script. 
   
7. Once you have your final config file, you may begin running the operation. 
   Make certain to specify the user of proxies and a delay (to avoid 403 errors)

```shell
pipenv run python app.py amazon-aio --proxies --delay 7
```
