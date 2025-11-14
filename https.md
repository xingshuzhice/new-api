Https证书


# 创建必要的符号链接
sudo ln -s /var/lib/snapd/snap /snap

1. 安装软件
	apt install  snapd
	snap install --classic certbot

2. 申请证书 按步骤执行
	certbot --nginx

  sudo certbot --nginx -d ai-api.xingshuzhice.com
  sudo certbot --nginx -d xingshuzhice.com

3.检查证书是否成功更新,列出所有证书，包括它们的日期
	sudo certbot certificates

4.手动添加定时任务
	sudo crontab -e
	0 3 * * * certbot renew --quiet && systemctl reload nginx		//这将是凌晨3点自动巡

5.检查是否已有定时任务（cron job 或 systemd）
	systemctl list-timers | grep certbot


6.这个会检查所有已经安装的证书，并自动更新命令
	sudo certbot renew

7.强制更新单个证书
	sudo certbot certonly --force-renew -d yourdomain.com

8.停止定时任务
	sudo systemctl stop snap.certbot.renew.timer
	sudo systemctl disable snap.certbot.renew.timer