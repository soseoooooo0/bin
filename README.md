# 莲花降落视频

这是一个可由 GitHub Actions 直接渲染的 8 秒方形 MP4 项目。

## 效果
1. 莲花在画面中央旋转出现。
2. 小孩从上方平缓降落到莲花中央。
3. 镜头在结尾快速推进，并出现白粉色闪光，形成震撼定格。

## 第一次使用：上传三张素材
在仓库中创建 `assets` 文件夹，并上传以下三张图（建议 PNG，透明背景效果最好）：

| 文件名 | 内容 |
| --- | --- |
| `assets/background.png` | 背景图；可用深色、天空或光效背景 |
| `assets/lotus.png` | 莲花，建议透明背景 |
| `assets/child.png` | 小孩，建议透明背景 |

> 这三个**文件名必须完全一致**。若你的图片是 JPG，请上传后在 GitHub 网页中改名为上述 `.png` 文件名；图片本身仍可为 JPG 格式。

## 一键生成 MP4
1. 打开仓库顶部的 **Actions**。
2. 选择 **Render lotus baby video**。
3. 点击 **Run workflow**，再点击绿色 **Run workflow**。
4. 等待约 1–3 分钟；打开完成的任务。
5. 在页面底部 **Artifacts** 下载 `lotus-baby-video`，解压即可得到 `lotus-baby.mp4`。

每次替换三张素材后，重新运行工作流即可。

## 本地预览（可选）
安装 FFmpeg 后运行：

```bash
bash scripts/render.sh
```

输出文件为 `output/lotus-baby.mp4`。
