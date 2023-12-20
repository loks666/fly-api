package middleware

import (
	"fly-api/common"
	"fmt"
	"github.com/gin-gonic/gin"
	"net/http"
)

func RelayPanicRecover() gin.HandlerFunc {
	return func(c *gin.Context) {
		defer func() {
			if err := recover(); err != nil {
				common.SysError(fmt.Sprintf("panic detected: %v", err))
				c.JSON(http.StatusInternalServerError, gin.H{
					"error": gin.H{
						"message": fmt.Sprintf("Panic detected, error: %v. Please submit a issue here: https://github.com/loks666/fly-api", err),
						"type":    "one_api_panic",
					},
				})
				c.Abort()
			}
		}()
		c.Next()
	}
}
