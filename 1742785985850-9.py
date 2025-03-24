import requests
from bs4 import BeautifulSoup
import markdown
import os
import time
import re

def fetch_webpage(url):
    """获取网页内容"""
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36'
    }
    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        return response.text
    except Exception as e:
        print(f"获取网页时发生错误：{e}")
        return None

def parse_cards(html_content):
    """解析HTML中的卡片内容"""
    soup = BeautifulSoup(html_content, 'html.parser')
    
    # 查找所有卡片元素
    cards = soup.find_all('div', class_='border text-card-foreground bg-background p-4 max-h-[calc(100vh-8rem)] aspect-square flex flex-col')
    
    results = []
    for card in cards:
        card_data = {}
        
        # 提取卡片内容
        code_content = card.find('code', class_='text-sm block pr-3')
        if code_content:
            card_data['content'] = code_content.text.strip()
        
        # 提取作者信息
        author_elem = card.find('h3', class_='font-semibold tracking-tight text-sm')
        if author_elem:
            card_data['author'] = author_elem.text.strip()
        
        # 提取技术标签
        tags = []
        tag_elems = card.find_all('span', class_='text-xs text-[#878787] font-mono flex-shrink-0')
        for tag in tag_elems:
            tag_text = tag.text.strip()
            if tag_text and not tag_text.startswith('+'):  # 过滤掉"+1 more"这样的标签
                tags.append(tag_text)
        
        card_data['tags'] = tags
        
        # 提取GitHub链接
        github_link = card.find('a', attrs={'href': re.compile(r'https://github.com/')})
        if github_link:
            card_data['github'] = github_link.get('href')
        
        results.append(card_data)
    
    return results

def generate_markdown(cards_data):
    """生成Markdown文档"""
    markdown_content = "# Cursor Rules - Next.js\n\n"
    
    for i, card in enumerate(cards_data, 1):
        markdown_content += f"## {i}. {card.get('author', '未知作者')}\n\n"
        
        if 'tags' in card and card['tags']:
            markdown_content += "**技术标签:** " + ", ".join(card['tags']) + "\n\n"
        
        if 'github' in card:
            markdown_content += f"**GitHub:** [{card.get('github', '')}]({card.get('github', '')})\n\n"
        
        if 'content' in card:
            markdown_content += "### 规则内容\n\n```\n" + card.get('content', '') + "\n```\n\n"
        
        markdown_content += "---\n\n"
    
    return markdown_content

def save_to_file(content, filename="cursor_rules_supabase.md"):
    """保存内容到文件"""
    with open(filename, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"内容已保存到 {filename}")

def main():
    url = "https://cursor.directory/rules/supabase"
    print(f"开始爬取网页: {url}")
    
    # 获取网页内容
    html_content = fetch_webpage(url)
    if not html_content:
        print("获取网页内容失败，程序退出")
        return
    
    # 解析卡片
    print("解析卡片内容...")
    cards_data = parse_cards(html_content)
    print(f"共找到 {len(cards_data)} 个卡片")
    
    # 生成Markdown
    print("生成Markdown文档...")
    markdown_content = generate_markdown(cards_data)
    
    # 保存到文件
    save_to_file(markdown_content)

if __name__ == "__main__":
    start_time = time.time()
    main()
    print(f"程序执行完毕，耗时 {time.time() - start_time:.2f} 秒")