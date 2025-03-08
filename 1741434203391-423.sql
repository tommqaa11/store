-- 删除所有表（按照与创建相反的顺序）
DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS fashion_square_images;
DROP TABLE IF EXISTS likes;
DROP TABLE IF EXISTS fashion_square;
DROP TABLE IF EXISTS hard_labels;
DROP TABLE IF EXISTS fashion_reviews;
DROP TABLE IF EXISTS virtual_fitting_items;
DROP TABLE IF EXISTS virtual_fittings;
DROP TABLE IF EXISTS weather;
DROP TABLE IF EXISTS schedules;
DROP TABLE IF EXISTS outfit_evaluations;
DROP TABLE IF EXISTS outfits;
DROP TABLE IF EXISTS daily_outfit ;
DROP TABLE IF EXISTS wardrobe;
DROP TABLE IF EXISTS user_profiles;
DROP TABLE IF EXISTS user_follows;
DROP TABLE IF EXISTS interface_calls;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS clothing_categories;
DROP TABLE IF EXISTS colors;
DROP TABLE IF EXISTS seasons;

-- 用户表：存储系统用户的基本信息（最先创建，因为被其他表引用）
CREATE TABLE users (
    image_path VARCHAR(255) COMMENT '用户头像存储路径',
    user_id VARCHAR(50) PRIMARY KEY COMMENT '用户唯一标识',
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    password_hash VARCHAR(255) NOT NULL COMMENT '密码哈希值',
    phone VARCHAR(100) NOT NULL UNIQUE COMMENT '用户手机号（唯一）',
    if_auto_recommend BOOLEAN DEFAULT FALSE COMMENT '是否自动推荐',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间'
);

-- 用户关注表：存储用户关注的人
CREATE TABLE user_follows (
    follow_id VARCHAR(50) PRIMARY KEY COMMENT '关注记录唯一标识',
    user_id VARCHAR(50) NOT NULL COMMENT '关联用户ID',
    follow_user_id VARCHAR(50) NOT NULL COMMENT '关联关注用户ID',
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (follow_user_id) REFERENCES users(user_id)
);
-- 用户信息表：存储用户的外观形象细节，用于更精准的穿搭推荐
CREATE TABLE user_profiles (
    profile_id VARCHAR(50) PRIMARY KEY COMMENT '信息记录唯一标识',
    user_id VARCHAR(50) NOT NULL COMMENT '关联用户ID',
    gender ENUM('male', 'female', 'other') COMMENT '用户性别',
    age INT COMMENT '用户年龄',
    height DECIMAL(5,2) COMMENT '用户身高（cm）',
    weight DECIMAL(5,2) COMMENT '用户体重（kg）',
    body_shape VARCHAR(50) COMMENT '体型描述',
    style_preference TEXT COMMENT '风格偏好',
    skin_tone VARCHAR(50) COMMENT '肤色（如：白皙、小麦色等）',
    hair_color VARCHAR(50) COMMENT '发色',
    hair_length ENUM('short', 'medium', 'long') COMMENT '头发长度',
    hair_style VARCHAR(50) COMMENT '发型（如：直发、卷发等）',
    eye_color VARCHAR(50) COMMENT '眼睛颜色',
    face_shape VARCHAR(50) COMMENT '脸型（如：圆形、方形等）',
    body_type VARCHAR(50) COMMENT '体型（如：梨形、苹果形等）',
    tattoo_description TEXT COMMENT '纹身描述',
    piercing_description TEXT COMMENT '穿孔描述',
    other_features TEXT COMMENT '其他特征描述',
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 下面三个表都是int枚举类型，有额外
-- 新增衣物类别维度表
CREATE TABLE clothing_categories (
    category_id VARCHAR(50) PRIMARY KEY COMMENT '类别ID',
    category_name VARCHAR(50) NOT NULL COMMENT '类别名称',
    category_description TEXT COMMENT '类别描述'
);

-- 新增颜色维度表
CREATE TABLE colors (
    color_id VARCHAR(50) PRIMARY KEY COMMENT '颜色ID',
    color_name VARCHAR(50) NOT NULL COMMENT '颜色名称'
);

-- 新增季节维度表
CREATE TABLE seasons (
    season_id VARCHAR(50) PRIMARY KEY COMMENT '季节ID',
    season_name VARCHAR(50) NOT NULL COMMENT '季节名称'
);

-- 衣柜表：存储用户上传的衣物信息
CREATE TABLE wardrobe (
    clothing_id VARCHAR(50) PRIMARY KEY COMMENT '衣物唯一标识',
    user_id VARCHAR(50) NOT NULL COMMENT '关联用户ID',
    clothing_type VARCHAR(50) NOT NULL COMMENT '衣物类型(全身，上半身，下半身)',
    category_id VARCHAR(50) NOT NULL COMMENT '衣物类别ID',
    color_id VARCHAR(50) COMMENT '颜色ID',
    season_id VARCHAR(50) COMMENT '适用季节ID',
    style VARCHAR(50) COMMENT '风格',
    image_path VARCHAR(255) COMMENT '衣物图片存储路径',
    description TEXT COMMENT '详细描述',
    if_delete BOOLEAN DEFAULT FALSE COMMENT '是否删除',
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (category_id) REFERENCES clothing_categories(category_id),
    FOREIGN KEY (color_id) REFERENCES colors(color_id),
    FOREIGN KEY (season_id) REFERENCES seasons(season_id)
);

-- 虚拟试衣表：存储虚拟试衣记录
CREATE TABLE virtual_fittings (
    fitting_id VARCHAR(50) PRIMARY KEY COMMENT '试衣记录唯一标识',
    user_id VARCHAR(50) NOT NULL COMMENT '关联用户ID',
    result_image VARCHAR(255) COMMENT '虚拟试衣合成图片路径',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    if_delete BOOLEAN DEFAULT FALSE COMMENT '是否删除',
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 虚拟试衣衣物关联表：处理虚拟试衣记录和衣物ID的多对多关系
CREATE TABLE virtual_fitting_items (
    fitting_item_id VARCHAR(50) PRIMARY KEY COMMENT '关联记录唯一标识',
    fitting_id VARCHAR(50) NOT NULL COMMENT '关联试衣记录ID',
    clothing_id VARCHAR(50) NOT NULL COMMENT '关联衣物ID',
    FOREIGN KEY (fitting_id) REFERENCES virtual_fittings(fitting_id),
    FOREIGN KEY (clothing_id) REFERENCES wardrobe(clothing_id)
);

-- 穿搭方案表：存储系统生成的穿搭方案
-- 临时的图片怎么处理呢？base64编码就行了
CREATE TABLE outfits (
    outfit_id VARCHAR(50) PRIMARY KEY COMMENT '穿搭方案唯一标识',
    user_id VARCHAR(50) NOT NULL COMMENT '关联用户ID',
    outfit_description TEXT NOT NULL COMMENT '穿搭方案描述',
    ai_prompt_description TEXT NOT NULL COMMENT 'AI生成提示词描述',
    outfit_image_url VARCHAR(255) COMMENT '穿搭方案图片URL',
    date DATE NOT NULL COMMENT '日期',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    requirement_text TEXT NOT NULL COMMENT '需求描述',
    scene_id VARCHAR(50) NOT NULL COMMENT '搭配场景ID(这里我不用枚举了，采用约束)',
    highlight_image_url VARCHAR(50) COMMENT '突出形象目标(用#分隔开)',
    if_delete BOOLEAN DEFAULT FALSE COMMENT '是否删除',
    if_evaluate BOOLEAN DEFAULT FALSE COMMENT '是否评价',
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 每日一搭
CREATE TABLE daily_outfit (
    daily_outfit_id VARCHAR(50) PRIMARY KEY COMMENT '每日穿搭方案唯一标识',
    user_id VARCHAR(50) NOT NULL COMMENT '关联用户ID',
    daily_outfit_description TEXT NOT NULL COMMENT '穿搭方案描述',
    ai_prompt_description TEXT NOT NULL COMMENT 'AI生成提示词描述',
    date DATE NOT NULL COMMENT '日期',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    if_delete BOOLEAN DEFAULT FALSE COMMENT '是否删除',
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);



-- 穿搭评价表：存储用户对穿搭方案的评价
CREATE TABLE outfit_evaluations (
    evaluation_id VARCHAR(50) PRIMARY KEY COMMENT '评价记录唯一标识',
    user_id VARCHAR(50) NOT NULL COMMENT '关联用户ID',
    outfit_id VARCHAR(50) NOT NULL COMMENT '关联穿搭方案ID',
    evaluation_text TEXT COMMENT '评价内容',
    rating INT CHECK (rating BETWEEN 1 AND 5) COMMENT '评分限制在1-5分',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '评价时间',
    if_delete BOOLEAN DEFAULT FALSE COMMENT '是否删除',
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (outfit_id) REFERENCES outfits(outfit_id)
);

-- 日程表：存储用户的日程信息，用于智能穿搭推荐
CREATE TABLE schedules (
    schedule_id VARCHAR(50) PRIMARY KEY COMMENT '日程唯一标识',
    user_id VARCHAR(50) NOT NULL COMMENT '关联用户ID',
    date DATE NOT NULL COMMENT '日程日期',
    event_describe TEXT COMMENT '事件描述',
    notes TEXT COMMENT '附加备注',
    reminder BOOLEAN DEFAULT FALSE COMMENT '提醒功能',
    if_delete BOOLEAN DEFAULT FALSE COMMENT '是否删除',
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 天气模块表：存储用户所在位置的天气信息
-- 天天怎么在庞大的用户身上自动记录？用户最近所在位置来查当天天气。
-- 在直接返回给前端的时候是都调api吧（或者先数据库，没有今日的再api）
-- 还可以加个简易穿搭或出行建议的挂件子模块（比如说天气冷注意保暖等等）
CREATE TABLE weather (
    weather_id VARCHAR(50) PRIMARY KEY COMMENT '天气记录唯一标识',
    user_id VARCHAR(50) NOT NULL COMMENT '关联用户ID',
    date DATE NOT NULL COMMENT '日期',
    location VARCHAR(100) COMMENT '用户所在位置',
    temperature VARCHAR(50) COMMENT '温度范围（℃）',
    weather_type VARCHAR(50) COMMENT '天气类型',
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- AI评价表：存储AI对用户穿搭的评价
CREATE TABLE fashion_reviews (
    review_id VARCHAR(50) PRIMARY KEY COMMENT '评价记录唯一标识',
    user_id VARCHAR(50) NOT NULL COMMENT '关联用户ID',
    image_path VARCHAR(255) COMMENT '用户上传图片路径',
    description TEXT COMMENT '附加描述信息',
    advantages TEXT COMMENT '优点',
    disadvantages TEXT COMMENT '不足',
    suggestions TEXT COMMENT '建议',
    score INT COMMENT 'AI评分（1-10分）',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    if_delete BOOLEAN DEFAULT FALSE COMMENT '是否删除',
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE hard_labels (
    label_id VARCHAR(50) PRIMARY KEY COMMENT '硬标签唯一标识',
    label_name VARCHAR(50) NOT NULL COMMENT '硬标签名称'
);

-- 穿搭广场表：存储用户在穿搭广场的分享内容
CREATE TABLE fashion_square (
    post_id VARCHAR(50) PRIMARY KEY COMMENT '动态唯一标识',
    soft_label VARCHAR(100) COMMENT '自定义软标签(用#分隔开)',
    hard_label VARCHAR(100) COMMENT '硬标签(枚举类别：生活，工作，休闲，运动，聚会，约会，其他)',
    user_id VARCHAR(50) NOT NULL COMMENT '关联用户ID',
    ip_address VARCHAR(50) COMMENT 'IP地址',
    content TEXT NOT NULL COMMENT '动态内容（文字）',
    likes INT DEFAULT 0 COMMENT '点赞数',
    comments INT DEFAULT 0 COMMENT '评论数',
    views INT DEFAULT 0 COMMENT '浏览量',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
    if_delete BOOLEAN DEFAULT FALSE COMMENT '是否删除',
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (hard_label) REFERENCES hard_labels(label_id)
);

-- 点赞记录表：存储用户对穿搭广场动态的点赞记录 
-- 这里用硬删除
CREATE TABLE likes (
    like_id VARCHAR(50) PRIMARY KEY COMMENT '点赞记录唯一标识',
    post_id VARCHAR(50) NOT NULL COMMENT '关联动态ID',
    user_id VARCHAR(50) NOT NULL COMMENT '关联用户ID',
    FOREIGN KEY (post_id) REFERENCES fashion_square(post_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
-- 穿搭广场图片表：存储用户在穿搭广场分享的图片
CREATE TABLE fashion_square_images (
    image_id VARCHAR(50) PRIMARY KEY COMMENT '图片唯一标识',
    post_id VARCHAR(50) NOT NULL COMMENT '关联动态ID',
    image_or_video_path VARCHAR(255) NOT NULL COMMENT '图片或视频存储路径',
    is_video BOOLEAN DEFAULT FALSE COMMENT '是否为视频',
    if_delete BOOLEAN DEFAULT FALSE COMMENT '是否删除',
    FOREIGN KEY (post_id) REFERENCES fashion_square(post_id)
);

-- 评论表：存储用户对穿搭广场动态的评论
CREATE TABLE comments (
    comment_id VARCHAR(50) PRIMARY KEY COMMENT '评论唯一标识',
    post_id VARCHAR(50) NOT NULL COMMENT '关联动态ID',
    user_id VARCHAR(50) NOT NULL COMMENT '关联用户ID',
    content TEXT NOT NULL COMMENT '评论内容',
    parent_comment_id VARCHAR(50) DEFAULT NULL COMMENT '父评论ID',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '评论时间',
    if_delete BOOLEAN DEFAULT FALSE COMMENT '是否删除',
    FOREIGN KEY (post_id) REFERENCES fashion_square(post_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
); 

-- 用户接口生成调用记录
CREATE TABLE interface_calls (
    call_id VARCHAR(50) PRIMARY KEY COMMENT '调用记录唯一标识',
    user_id VARCHAR(50) NOT NULL COMMENT '关联用户ID',
    interface_name VARCHAR(50) NOT NULL COMMENT '接口名称',
    ip_address VARCHAR(50) COMMENT 'IP地址',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
