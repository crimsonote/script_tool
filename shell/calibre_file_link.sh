#!/bin/bash

# 定义calibre数据库的路径
calibre_db_path="$1"

# 定义软连接存放的根目录
link_root="$2"

# 使用calibredb命令获取图书信息并转化为JSON格式
# 由于calibredb不允许在已经运行了calibre的情况下执行，所以这里使用fackroot工具使其忽略这一点。
books=$(fakeroot calibredb list -f authors,id,title,formats --for-machine --with-library="${calibre_db_path}")

# 遍历每个图书
IFS=$'\n\n'
for book in $(echo "${books}" | jq -c '.[]'); do

    # 解析图书信息
  author=$(echo "${book}" | jq -r '.authors')
  id=$(echo "${book}" | jq -r '.id')
  title=$(echo "${book}" | jq -r '.title')
  formats=$(echo "${book}" | jq -r '.formats')
  # 创建作者目录和书名目录
  author_dir="${link_root}/${author}"
  book_dir="${author_dir}/${id}-${title}"
  mkdir -p "${author_dir}" "${book_dir}"
  # 遍历图书的每个格式，创建软连接
  for format in $(echo ${formats}|jq -c .[]|tr -d '"'); do
      # 获取文件名和文件后缀
    filename=$(basename "${format}")
    extension="${filename##*.}"
    # 创建软连接
    ln -s "${format}" "${book_dir}/${title}.${extension}"
  done
done
