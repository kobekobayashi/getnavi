class Scraping
  #
  # function getElementByXpath(path) {
  #   return document.evaluate(path, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
  # }

  @@BASE_URL = "https://getnavi.jp/"
  @@category_url = "homeappliances"

  XPATH = {
      'img': "//div[@class='img']//img/@src",
      'title': "//div[@class='title']//text()"
    }

  DETAIL_XPATH = {
    'name': "//h1[@class='entry-title']//text()"
  }

  def get_category_url
    puts "get_category_url :#{@@BASE_URL << 'category/' << @@category_url}"
    @@BASE_URL << 'category/' << @@category_url
  end

  def next_xpath
    "//nav[@class='navigation pagination']//a[@class='next page-numbers']/@href"
  end

  def detail_xpath(num)
    "//div[@class='inner']/div[@class='box'][#{num}]"
  end

  def last_detail_tile
    "//div[@class='inner']/div[@class='box'][last()]//div[@class='title']//text()"
  end

  def product_detail(data, url)
    agent = Mechanize.new
    detail_page = agent.get(url)
    data[:name] = detail_page.at(DETAIL_XPATH[:name]).text if detail_page
    return data
  end

  def get_products
    url = get_category_url
    agent = Mechanize.new
    categories_page = agent.get(url)
    last_title = categories_page.at(last_detail_tile).text
    cnt = 1

    loop do
      data = Hash.new
      detail = categories_page.at(detail_xpath(cnt))
      data[:img] = detail.at(detail_xpath(cnt) + XPATH[:img]).value if detail
      data[:title] = detail.at(detail_xpath(cnt) + XPATH[:title]).text if detail
      detail_url = categories_page.at(detail_xpath(cnt) << "//a/@href")
      data = product_detail(data, detail_url.value) if detail_url.value
      pp data
      save_product(data)
      if last_title == data[:title] && next_xpath.present?
        sleep(2)
        agent = Mechanize.new
        next_url = categories_page.at(next_xpath).value
        categories_page = agent.get(next_url)
        last_title = categories_page.at(last_detail_tile).text
        cnt = 1
      elsif last_title == data[:title] && next_xpath.blank?
        break
      else
      end
      cnt += 1
    end
  end

  def save_product(data)
    product = Product.where(title: data[:title]).first_or_initialize
    product.title = data[:title]
    product.image = data[:img]
    product.name = data[:name]
    product.save
  end
end
